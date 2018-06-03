require "open-uri"

class MonitorWorker
  attr_reader :logger, :tracker

  def initialize(bot, logger)
    @bot = bot
    @logger = logger
    @tracker = ItemTracker.new(fetch_posts)
  end

  def work!
    begin
      new = tracker.add_and_return_new(fetch_posts)

      new.each do |post|
        begin
          logger.info("NEW: #{post.updated} #{post.id} #{post.title}")
          bot.send_message(Settings.log_channel, "NEW: #{post.updated} #{post.id} #{post.title}") if Settings.log_channel

          if Settings.monitoring_enabled
            if post.gb?
              Channel.where(gb_alerts: true).each do |channel|
                bot.send_message(channel.id, *post.to_discord_message)
              end
            end

            searches = Search.matching(post.title, post.submitter)

            searches.each do |search|
              user = bot.user(search.user_id)
              logger.info("MATCH: #{user.username.truncate(8)} for \"#{search.query}\" on \"#{search.highlighted_query_match(post.title)}\"")
              bot.send_message(Settings.log_channel, "MATCH: #{user.username.truncate(8)} for \"#{search.query}\" on \"#{search.highlighted_query_match(post.title)}\"") if Settings.log_channel
              user.pm.send_message(*post.to_discord_message(search))
            end
          end
        rescue Parslet::ParseFailed => error
          logger.error("error parsing #{post.raw_title}:")
          logger.error(error.parse_failure_cause.ascii_tree)
        end
      end
    rescue => e
      logger.error e
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
