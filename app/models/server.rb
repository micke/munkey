class Server < ActiveRecord::Base
  has_many :regions
  has_many :channels

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

  def discord
    @on_discord ||= BOT.servers[id]
  rescue RuntimeError
    nil
  end

  def channel_count
    channels.count
  end

  delegate :icon_url, :member_count, to: :discord, allow_nil: true
end
