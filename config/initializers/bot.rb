# frozen_string_literal: true

require_relative "../../lib/bot"
if ENV["DISCORD_TOKEN"]
  Thread.new do
    puts "Starting bot"
    BOT.run
    puts "Bot stopped, killing rails..."
    Process.kill "SIGTERM", Process.pid
  end
end
