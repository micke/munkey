class Region < ActiveRecord::Base
  belongs_to :server

  default_scope { order("position asc") }

  def self.upsert!(discord_role)
    find_or_create_by(
      server_id: discord_role.server.id,
      id: discord_role.id,
    ).tap do |region|
      region.update_with_discord_role(discord_role)
    end
  end

  def discord
    @on_discord ||= server.discord.role(id)
  rescue RuntimeError
    nil
  end

  def update_with_discord_role(discord_role)
    update!(
      name: discord_role.name,
      color: discord_role.color.hex,
      position: discord_role.position,
    )
  end

  def update_from_discord!
    return unless discord

    Region.upsert! discord
  end
end
