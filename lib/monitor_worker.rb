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

          searches.each do |search|
            logger.match(post, search)
            search.discord_user.pm.send_message(*post.to_discord_message(search))
          end
        end
      rescue Parslet::ParseFailed => error
        logger.parser_error(post, error)
      end
    end
  end

  private

  attr_reader :bot

  def search_uri
    "https://www.reddit.com/r/mechmarket/new.rss"
  end

  def fetch_posts
    SimpleRSS.parse(open(search_uri, "User-Agent" => "redditnotifier/1.0")).items.map do |item|
      RedditPost.new(item)
    end.sort_by(&:updated)
  end
end
