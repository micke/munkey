STDOUT.sync = true
require "bundler"
Bundler.require
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

LOGGER = Logger.new(STDOUT)

project_root = File.dirname(File.absolute_path(__FILE__))
Dir.glob(project_root + "/lib/*.rb").each{|f| require f}

DB.connect
DB.migrate

Settings.default :monitoring_enabled, true
Settings.default :log_channel, nil

bot = Discordrb::Commands::CommandBot.new(
  token: ENV.fetch("DISCORD_TOKEN"),
  client_id: ENV.fetch("DISCORD_CLIENT_ID"),
  prefix: ".",
)

ADMIN_PERMISSIONS = { required_permissions: [:can_administrate] }

bot.command :add, ADMIN_PERMISSIONS.merge(min_args: 1) do |event, user|
  parsed_user = bot.parse_mention(user)
  if User.exists?(parsed_user.id)
    "#{event.user.mention} #{user} is already added"
  else
    User.add(parsed_user)
    "#{event.user.mention} Added #{user}"
  end
end

bot.command :enable, ADMIN_PERMISSIONS do |event|
  Settings.monitoring_enabled = true
  "Monitoring enabled"
end

bot.command :disable, ADMIN_PERMISSIONS do |event|
  Settings.monitoring_enabled = false
  "Monitoring disabled"
end

bot.command :botlog, ADMIN_PERMISSIONS do |event|
  Settings.log_channel = event.channel.id
  "Log channel set"
end

bot.command :invite, ADMIN_PERMISSIONS do |event|
  event.bot.invite_url
end

bot.message in: "visa-din-keeb" do |event, *args|
  return unless ENV["GOOGLE_CLOUD_PROJECT"] && ENV["GOOGLE_CLOUD_KEYFILE_JSON"]
  embed_images = event.message.embeds.select { |e| e.type == :image }.collect { |e| e.url }
  attached_images = event.message.attachments.select { |a| a.image? }.collect { |a| a.url }
  images = embed_images | attached_images
  image_files = []
  if images.any?
    description_message = event.send_message "Analyzing..."

    begin
      vision = Google::Cloud::Vision.new
      keeb_image = false

      images.each do |image|
        is = image.split("/")
        image_name = "#{is[-2]}_#{is[-1]}"
        File.open(image_name, "wb") do |fo|
          fo.write open(image).read
        end
        image_files << image_name
        vision_image = vision.image(image_name)
        labels = vision_image.labels
        LOGGER.info("IMAGE: #{event.user.username} #{labels.collect(&:description)}")

        if labels.any? { |l| l.description =~ /keyboard/i }
          keeb_image = true
          break
        end
      end

      if keeb_image
        pins = event.channel.pins.sort_by(&:timestamp)

        until pins.count < 50
          pins.shift.unpin
        end

        event.message.pin
      end
    rescue => e
      LOGGER.error(e)
      event.message.pin
      description_message.edit("#{event.user.mention} Whops, I'm having problems analyzing your image")
    ensure
      description_message.delete
      FileUtils.rm image_files, :force => true 
    end
  end
end

bot.command :block, ADMIN_PERMISSIONS.merge(min_args: 1) do |event, user|
  parsed_user = bot.parse_mention(user)
  User.block(parsed_user)
  "#{event.user.mention} Blocked #{user}"
end

bot.command :unblock, ADMIN_PERMISSIONS.merge(min_args: 1) do |event, user|
  parsed_user = bot.parse_mention(user)
  User.unblock(parsed_user)
  "#{event.user.mention} Unblocked #{user}"
end

bot.command :monitor, min_args: 1, description: "Adds a new search that will be monitored for new posts on r/mechmarket" do |event, *args|
  return unless User.allowed?(event.user)

  user = Utils.subject(bot, event, args)

  if args.empty?
    event << "#{user.mention} You need to give me a pattern to monitor for!"
    return
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

bot.command :unmonitor, min_args: 1, max_args: 2, description: "Removes a phrase so that it will not be monitored for new posts on r/mechmarket anymore" do |event, *args|
  return unless User.allowed?(event.user)

  user = Utils.subject(bot, event, args)

  id = args.join.to_i

  unless id
    event << "#{user.mention} You need to give me a search id to remove"
    return
  end

  search = Search.find_by(id: id, user_id: user.id)

  unless search
    "#{user.mention} no search found with id #{id}"
  else
    search.destroy
    "#{user.mention} No longer monitoring for #{search.description}"
  end
end

bot.message do |event|
  if event.message.content =~ /\.(.+)/
    server = Server.upsert!(event.server)
    if role = server.regions.where(name: $1).first
      # Remove other region regions
      existing_region_roles = event.user.roles.collect(&:id) & server.regions.pluck(:discord_id)

      # Add new region role
      event.user.modify_roles(role.discord_id, existing_region_roles)
      event.message.delete
    end
  end
end

bot.command :regions do |event|
  server = Server.upsert!(event.server)
  event << "Regions:"
  server.regions.order(:name).all.each do |role|
    event << ".#{role.name.downcase}"
  end

  event << ""
  event << "To get a role just reply with the role, your message will be deleted when you get the role."
  event << "Example; .#{server.regions.first&.name&.downcase || "stockholm"}"
end

bot.command :createregion, ADMIN_PERMISSIONS do |event, name|
  server = Server.upsert!(event.server)
  return if server.regions.exists?(name: name)
  discord_role = event.server.create_role
  discord_role.name = name
  region = server.regions.create!(name: name, discord_id: discord_role.id)

  "Created region #{region.name}"
end

bot.command :removeregion, ADMIN_PERMISSIONS do |event, name|
  server = Server.upsert!(event.server)
  region = server.regions.find_by_name(name)

  unless region
    "Region #{name} not found"
  else
    discord_role = event.server.role(region.discord_id)
    discord_role.delete if discord_role
    region.destroy

    "Removed region #{region.name}"
  end
end

bot.command :renameregion, ADMIN_PERMISSIONS do |event, name, new_name|
  server = Server.upsert!(event.server)
  region = server.regions.find_by_name(name)

  unless region
    "Region #{name} not found"
  else
    discord_role = event.server.role(region.discord_id)
    discord_role.name = new_name
    region.update!(name: new_name)

    "Renamed region #{region.name}"
  end
end

bot.command :monitors, description: "Lists all phrases that the bot monitors for you on r/mechmarket" do |event, *args|
  return unless User.allowed?(event.user)

  user = Utils.subject(bot, event, args)

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

bot.command :unmonitorall, description: "Removes all monitored phrases" do |event, *args|
  return unless User.allowed?(event.user)

  subject = Utils.subject(bot, event, args)
  user = User.find(subject.id)

  if user.searches.any?
    user.searches.destroy_all
    "#{subject.mention} Removed all monitored searches"
  else
    "#{subject.mention} don't have any monitored searches"
  end
end

bot.command :tokenize, description: "Returns the search tokenized" do |event, *args|
  return unless User.allowed?(event.user)

  search = Search.parse(args)
  if search.errors.any?
    search.errors.full_messages.join(", ")
  else
    event << "Tokenizing \"#{args.join(" ")}\" becomes:"
    event << search.description
  end
end

bot.command :enable_gb_alerts, ADMIN_PERMISSIONS do |event, *args|
  channel = Channel.upsert!(event.channel)
  channel.enable_gb_alerts!
  "GB alerts enabled in this channel"
end

bot.command :disable_gb_alerts, ADMIN_PERMISSIONS do |event, *args|
  channel = Channel.upsert!(event.channel)
  channel.disable_gb_alerts!
  "GB alerts disabled in this channel"
end

bot.member_leave do |event|
  user = User.find(event.user.id)

  if user
    user.searches.destroy_all
    puts "Removed all monitors for #{event.user.username} ##{event.user.id}"
  end
end

bot.run :async

worker = MonitorWorker.new(bot)
worker.work!
