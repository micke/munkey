# frozen_string_literal: true

module Bot
  module ChannelCrud
    extend Discordrb::EventContainer

    TEXT_CHANNEL_TYPE = 0

    channel_create type: TEXT_CHANNEL_TYPE do |event|
      Channel.upsert!(event.channel)
    end

    channel_update type: TEXT_CHANNEL_TYPE do |event|
      Channel.upsert!(event.channel)
    end

    channel_delete type: TEXT_CHANNEL_TYPE do |event|
      Channel.destroy(event.id)
    end
  end
end
