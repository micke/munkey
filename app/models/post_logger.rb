# frozen_string_literal: true

class PostLogger
  def initialize(logger, bot = nil)
    @logger = logger
    @bot = bot
  end

  def new(post)
    info("NEW: #{post.updated} #{post.id} #{post.title}")
  end

  def match(post, search)
    info("MATCH: #{search.user_name.truncate(8)} for \"#{search.query}\" on \"#{search.highlighted_query_match(post.title)}\"")
  end

  def parser_error(post, error)
    logger.error("error parsing #{post.raw_title}:")
    logger.error(error.parse_failure_cause.ascii_tree)
  end

  %i(debug info warn error fatal).each do |level|
    define_method level do |message|
      logger.public_send(level, message)
      log_to_discord(message)
    end
  end

  private

  attr_reader :logger, :bot

  def log_to_discord(message)
    bot.send_message(Settings.log_channel, message) if Settings.log_channel
  end
end
