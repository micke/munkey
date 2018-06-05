# frozen_string_literal: true

class Utils
  def self.subject(bot, event, args)
    if event.user.can_administrate? && bot.parse_mention(args[0])
      user = bot.parse_mention(args[0])
      args.shift
      user
    else
      event.user
    end
  end

  def self.clean(args)
    args.gsub(/[^a-z0-9\-_\ :\*()&!<>|]/i, "").squeeze(" ").strip
  end
end
