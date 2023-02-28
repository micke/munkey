# frozen_string_literal: true

module Bot
  ADMIN_PERMISSIONS = { required_permissions: [:can_administrate] }
end

require_relative "bot/channel_extensions"
require_relative "bot/message_extensions"
require_relative "bot/server_extensions"

require_relative "bot/channel_crud"
require_relative "bot/group_buys"
require_relative "bot/image_processing"
require_relative "bot/market"
require_relative "bot/regions"
require_relative "bot/searches"
require_relative "bot/server_crud"
require_relative "bot/loyalty_roles"

Settings.default :monitoring_enabled, true
Settings.default :log_channel, nil

sentry_error_reporter = ->(event, exception) {
  Raven.user_context username: event.user.username
  Raven.tags_context channel: event.channel.name
  Raven.extra_context content: event.content
  Raven.capture_exception exception
}

BOT = Discordrb::Commands::CommandBot.new(
  token: ENV.fetch("DISCORD_TOKEN", "1337"),
  client_id: ENV.fetch("DISCORD_CLIENT_ID", "1337"),
  prefix: ".",
  rescue: sentry_error_reporter,
)

bot = BOT

bot.include! Bot::Regions
bot.include! Bot::Searches
bot.include! Bot::GroupBuys
bot.include! Bot::ImageProcessing
bot.include! Bot::ChannelCrud
bot.include! Bot::ServerCrud
bot.include! Bot::Market
bot.include! Bot::LoyaltyRoles

bot.command :botlog, Bot::ADMIN_PERMISSIONS do |event|
  Settings.log_channel = event.channel.id
  "Log channel set"
end

bot.command :link do
  bot.invite_url
end

bot.command :stop, Bot::ADMIN_PERMISSIONS do |event|
  event << "bye bye"
  bot.stop
end
