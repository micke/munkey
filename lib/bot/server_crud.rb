# frozen_string_literal: true

module Bot
  module ServerCrud
    extend Discordrb::EventContainer

    TEXT_CHANNEL_TYPE = 0

    server_create do |event|
      Server.upsert!(event.server).update_from_discord!
    end

    server_update do |event|
      Server.upsert!(event.server)
    end

    server_delete do |event|
      Server.destroy(event.server.id)
    end
  end
end
