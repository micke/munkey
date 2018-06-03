class Channel < ActiveRecord::Base
  belongs_to :server

  default_scope { order("position asc") }

  def self.upsert!(discord_channel)
    find_or_create_by!(
      id: discord_channel.id,
      server_id: discord_channel.server.id
    ).tap do |channel|
      channel.update_with_discord_channel(discord_channel)
    end
  end

  def update_with_discord_channel(discord_channel)
    update!(
      name: discord_channel.name,
      topic: discord_channel.topic,
      position: discord_channel.position
    )
  end

  def enable_gb_alerts!
    update!(gb_alerts: true)
  end

  def disable_gb_alerts!
    update!(gb_alerts: false)
  end
end
