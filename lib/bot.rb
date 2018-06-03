module Bot
  ADMIN_PERMISSIONS = { required_permissions: [:can_administrate] }
end

require_relative "bot/channel_extensions"
require_relative "bot/message_extensions"
require_relative "bot/server_extensions"

require_relative "bot/regions"
require_relative "bot/searches"
require_relative "bot/group_buys"
require_relative "bot/image_processing"

Settings.default :monitoring_enabled, true
Settings.default :log_channel, nil

BOT = Discordrb::Commands::CommandBot.new(
  token: ENV.fetch("DISCORD_TOKEN"),
  client_id: ENV.fetch("DISCORD_CLIENT_ID"),
  prefix: ".",
)

bot = BOT

bot.include! Bot::Regions
bot.include! Bot::Searches
bot.include! Bot::GroupBuys
bot.include! Bot::ImageProcessing

bot.command :botlog, Bot::ADMIN_PERMISSIONS do |event|
  Setting.log_channel = event.channel.id
  "Log channel set"
end

bot.command :pry do |event|
  binding.pry
end
