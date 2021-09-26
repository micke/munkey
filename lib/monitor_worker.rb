# frozen_string_literal: true

require "open-uri"

class MonitorWorker
  attr_reader :logger, :tracker

  def initialize(bot, logger)
    @bot = bot
    @logger = PostLogger.new(logger, bot)
    @tracker = ItemTracker.new(fetch_posts)
  end

  def work!
    new = tracker.add_and_return_new(fetch_posts)

    new.each do |post|
      begin
        logger.new(post)

        if Settings.monitoring_enabled
          if post.gb?
            Channel.receiving_gb_alerts.each do |channel|
              channel.send_message(*post.to_discord_message)
            end
          end

          searches = Search.matching(post.title, post.submitter)

          searches.map { |s| SearchDecorator.new(s) }.each do |search|
            logger.match(post, search)
            search.user.send_message(*post.to_discord_message(search))
          end
        end
      rescue Parslet::ParseFailed => error
        logger.parser_error(post, error)
      end
    end
  rescue => exception
    Raven.capture_exception(exception)
    raise exception
  end

  private

  attr_reader :bot

  def fetch_posts
    SimpleRSS.parse(connection.get("/r/mechmarket/new.rss").body).items.map do |item|
      RedditPost.new(item)
    end.sort_by(&:updated)
  end
  
  def connection
    @connection ||= Faraday.new(url: "https://www.reddit.com", headers: {"User-Agent" => "sweredditnotifier/1.0"}) do |faraday|
      faraday.adapter :typhoeus
    end
  end
end
