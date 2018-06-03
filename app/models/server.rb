class Server < ActiveRecord::Base
  has_many :regions, dependent: :destroy
  has_many :channels, dependent: :destroy

  def self.upsert!(discord_server)
    find_or_create_by(id: discord_server.id).tap do |server|
      server.update_with_discord_server(discord_server)
    end
  end

  def update_with_discord_server(discord_server)
    update!(
      name: discord_server.name
    )
  end

  def update_from_discord!
    Server.upsert!(discord)

    discord.text_channels.each do |channel|
      Channel.upsert!(channel)
    end

    regions.each do |region|
      region.update_from_discord!
    end
  end

  def discord
    @on_discord ||= BOT.servers[id]
  rescue RuntimeError
    nil
  end

  def channel_count
    channels.count
  end

  def region_count
    regions.count
  end

  delegate :icon_url, :member_count, to: :discord, allow_nil: true
end
