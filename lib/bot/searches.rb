module Bot
  module Searches
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    command :add, Bot::ADMIN_PERMISSIONS.merge(min_args: 1) do |event, user|
      parsed_user = event.bot.parse_mention(user)
      if User.exists?(parsed_user.id)
        "#{event.user.mention} #{user} is already added"
      else
        User.add(parsed_user)
        "#{event.user.mention} Added #{user}"
      end
    end

    command :enable, Bot::ADMIN_PERMISSIONS do |event|
      Setting.monitoring_enabled = true
      "Monitoring enabled"
    end

    command :disable, Bot::ADMIN_PERMISSIONS do |event|
      Setting.monitoring_enabled = false
      "Monitoring disabled"
    end

    command :invite, Bot::ADMIN_PERMISSIONS do |event|
      event.invite_url
    end

    command :block, Bot::ADMIN_PERMISSIONS.merge(min_args: 1) do |event, user|
      parsed_user = event.bot.parse_mention(user)
      User.block(parsed_user)
      "#{event.user.mention} Blocked #{user}"
    end

    command :unblock, Bot::ADMIN_PERMISSIONS.merge(min_args: 1) do |event, user|
      parsed_user = event.bot.parse_mention(user)
      User.unblock(parsed_user)
      "#{event.user.mention} Unblocked #{user}"
    end

    command :monitor, min_args: 1, description: "Adds a new search that will be monitored for new posts on r/mechmarket" do |event, *args|
      next unless User.allowed?(event.user)

      user = Utils.subject(event.bot, event, args)

      if args.empty?
        event << "#{user.mention} You need to give me a pattern to monitor for!"
        next
      end

      search = User.find(user.id).searches.parse(args)

      if Search.exists?(query: search.query, user_id: search.user_id, submitter: search.submitter)
        "#{user.mention} Already monitoring for #{search.description}"
      else
        if search.errors.any?
          search.errors.full_messages.join(", ")
        else
          search.save!
          "#{user.mention} Now monitoring for #{search.description}"
        end
      end
    end

    command :unmonitor, min_args: 1, max_args: 2, description: "Removes a phrase so that it will not be monitored for new posts on r/mechmarket anymore" do |event, *args|
      next unless User.allowed?(event.user)

      user = Utils.subject(event.bot, event, args)

      id = args.join.to_i

      unless id
        event << "#{user.mention} You need to give me a search id to remove"
        next
      end

      search = Search.find_by(id: id, user_id: user.id)

      unless search
        "#{user.mention} no search found with id #{id}"
      else
        search.destroy
        "#{user.mention} No longer monitoring for #{search.description}"
      end
    end

    command :monitors, description: "Lists all phrases that the bot monitors for you on r/mechmarket" do |event, *args|
      next unless User.allowed?(event.user)

      user = Utils.subject(event.bot, event, args)

      searches = User.find(user.id).searches

      if searches.any?
        event << "#{user.mention} monitored searches:"
        searches.each do |search|
          event << "#{search.id}. #{search.description}"
        end
        nil
      else
        "#{user.mention} don't have any monitored searches"
      end
    end

    command :unmonitorall, description: "Removes all monitored phrases" do |event, *args|
      next unless User.allowed?(event.user)

      subject = Utils.subject(event.bot, event, args)
      user = User.find(subject.id)

      if user.searches.any?
        user.searches.destroy_all
        "#{subject.mention} Removed all monitored searches"
      else
        "#{subject.mention} don't have any monitored searches"
      end
    end

    command :tokenize, description: "Returns the search tokenized" do |event, *args|
      next unless User.allowed?(event.user)

      search = Search.parse(args)
      if search.errors.any?
        search.errors.full_messages.join(", ")
      else
        event << "Tokenizing \"#{args.join(" ")}\" becomes:"
        event << search.description
      end
    end

    member_leave do |event|
      user = User.find(event.user.id)

      if user
        user.searches.destroy_all
        puts "Removed all monitors for #{event.user.username} ##{event.user.id}"
      end
    end
  end
end
