# frozen_string_literal: true

module Bot
  module Market
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    AD_PATTERN   = /\A\[h\](.+)\[w\](.+)/im
    PAYMENT_SERVICE_PATTERN = /swish|paypal|pengar/i
    MONETARY_PATTERN = /\d+\s*kr/im

    extend ActionView::Helpers::DateHelper

    command :market, ADMIN_PERMISSIONS do |event|
      channel = Channel.upsert!(event.channel)

      channel.update!(market: !channel.market)

      if channel.market?
        "Market mode enabled"
      else
        "Market mode disabled"
      end
    end

    command :delete_message_log_channel, ADMIN_PERMISSIONS do |event|
      channel = Channel.upsert!(event.channel)

      log_channel_discord = BOT.channel(event.message.content[/#(\d+)/, 1].to_i)
      log_channel = Channel.upsert!(log_channel_discord)

      channel.update!(delete_message_log_channel: log_channel)

      "Message delete log channel set to ##{log_channel.name}"
    end

    command :hours_required, ADMIN_PERMISSIONS do |event|
      channel = Channel.upsert!(event.channel)

      hours = event.message.content[/(\d+)/, 1].to_i

      channel.update!(hours_required_to_post: hours)

      "Hours required to post set to #{hours}!"
    end

    message do |event|
      next if event.author.can_administrate?

      channel = Channel.find_by(id: event.channel.id)

      if channel&.hours_required_to_post.to_i > 0 &&
          (Time.current - event.author.joined_at) / 1.hour < channel.hours_required_to_post

        event.author.pm <<~END
          Hej! Tyvärr har inte du varit medlem på servern tillräckligt länge för att posta i ##{event.channel.name}.
          Du har varit medlem i #{time_ago_in_words(event.author.joined_at)} och man behöver vara medlem i #{time_ago_in_words(channel.hours_required_to_post.hours.ago)}
        END

        event.message.delete
        next
      end

      next unless channel&.market?

      User.upsert!(event.author)
      Message.create!(id: event.message.id, content: event.message.content, author_id: event.author.id)

      unless event.content =~ AD_PATTERN
        event.author.pm <<~END
          Hej! Tyvärr tillåter vi bara annonser i ##{event.channel.name}.
          Ditt meddelande såg inte ut som en annons i mina ögon, men jag är ju bara en dum bot.
          Försökte du svara på en annons någon annan postade så ber vi dig skicka ett pm till personen.
          Vänligen formulera ditt meddelande som: [H] Vad du har [W] Vad du vill ha i utbyte.

          Meddelandet du försökte skicka var:
          #{event.content}
        END
        event.message.delete
        event.bot.send_message(Settings.log_channel, <<~END) if Settings.log_channel
          #{event.author.mention} in #{event.channel.mention}: #{event.content}
        END
      end

      if event.content =~ PAYMENT_SERVICE_PATTERN && event.content !~ MONETARY_PATTERN
        event.author.pm <<~END
          Hej! Du skapade precis en annons i ##{event.channel.name}.
          Och det ser ut som att du ber om betalning eller vill betala med swish eller paypal utan att ange hur mycket du vill ha eller hur mycket du är villig att ge.
          Vi rekommenderar att du redigerar din post och inkluderar den informationen så medlemmar som är intresserade slipper fråga om det.

          Lycka till!
        END
      end
    end

    message_edit do |event|
      next if event.author.can_administrate?

      channel = Channel.find_by(id: event.channel.id)

      next unless channel&.market?

      unless event.content =~ AD_PATTERN
        event.author.pm <<~END
          Hej! Tyvärr tillåter vi bara annonser i ##{event.channel.name}.
          Ditt meddelande såg inte ut som en annons i mina ögon, men jag är ju bara en dum bot.
          Försökte du svara på en annons någon annan postade så ber vi dig skicka ett pm till personen.
          Vänligen formulera ditt meddelande som: [H] Vad du har [W] Vad du vill ha i utbyte.

          Meddelandet du försökte skicka var:
          #{event.content}
        END
        event.message.delete
        event.bot.send_message(Settings.log_channel, <<~END) if Settings.log_channel
          #{event.author.mention} in #{event.channel.mention}: #{event.content}
        END
      end

      Message.find_or_initialize_by(id: event.message.id).update!(content: event.message.content)
    end

    message_delete do |event|
      channel = Channel.find(event.channel.id)

      next unless channel&.market? && channel&.delete_message_log_channel.present?

      message = Message.find_by(id: event.id)

      next unless message

      channel.delete_message_log_channel.discord.send_message(<<~END)
        #{message.author.discord.mention}: ~~#{message.content}~~
      END
    end
  end
end
