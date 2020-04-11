# frozen_string_literal: true

require_relative "../../lib/bot"
if ENV["DISCORD_TOKEN"]
  puts "Starting bot"
  BOT.run :async
end
