# frozen_string_literal: true

module Bot
  module Market
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    CHANNEL      = "köp-och-sälj"
    AD_PATTERN   = /\A\[h\](.+)\[w\](.+)/im
    PAYMENT_SERVICE_PATTERN = /swish|paypal/i
    MONETARY_PATTERN = /\d+\s*kr/im
    QUEUE        = []
    QUEUE_LENGTH = 200

    message in: CHANNEL do |event|
      next if event.author.can_administrate?

      unless event.content =~ AD_PATTERN
        event.author.pm <<~END
          Hej! Tyvärr tillåter vi bara annonser i ##{CHANNEL}.
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
          Hej! Du skapade precis en annons i ##{CHANNEL}.
          Och det ser ut som att du ber om betalning eller vill betala med swish eller paypal utan att ange hur mycket du vill ha eller hur mycket du är villig att ge.
          Vi rekommenderar att du redigerar din post och inkluderar den informationen så medlemmar som är intresserade slipper fråga om det.

          Lycka till!
        END
      end

      QUEUE << event.message
      QUEUE.shift until QUEUE.length < QUEUE_LENGTH
    end

    message_edit in: CHANNEL do |event|
      next if event.author.can_administrate?

      unless event.content =~ AD_PATTERN
        event.author.pm <<~END
          Hej! Tyvärr tillåter vi bara annonser i ##{CHANNEL}.
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

      QUEUE << event.message
      QUEUE.shift until QUEUE.length < QUEUE_LENGTH
    end

    message_delete in: CHANNEL do |event|
      message = QUEUE.find { |m| m.id == event.id }
      return unless message

      event.channel.send_message(<<~END)
        #{message.author.mention}: ~~#{message.content}~~
      END
    end
  end
end
