# frozen_string_literal: true

class LoyaltyRole < ActiveRecord::Base
  belongs_to :server

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
    )
  end

  def update_from_discord!
    return unless discord

    LoyaltyRole.upsert! discord
  end
end
