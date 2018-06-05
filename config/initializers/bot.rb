# frozen_string_literal: true

require_relative "../../lib/bot"
unless defined?(Rails::Console)
  BOT_LOG = File.open(Rails.root.join("log/bot.log"), "a+")
  BOT_LOG.sync = true
  Discordrb.const_get(:LOGGER).streams = [File.open(Rails.root.join("log/bot.log"), "a+")]
  BOT.run :async
end
