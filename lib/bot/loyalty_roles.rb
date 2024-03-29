# frozen_string_literal: true

module Bot
  module LoyaltyRoles
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    CHECK_AND_ADD_ROLE = ->(event) do
      return unless event.author.respond_to?(:joined_at)

      event
        .server
        .loyalty_roles
        .each do |loyalty_role|
          next unless event.author.joined_at <= loyalty_role.required_age.years.ago

          event.user.add_role(loyalty_role.id) unless event.user.role?(loyalty_role.id)
        end
    end

    command :addloyaltyrole, ADMIN_PERMISSIONS do |event, name, required_age|
      if discord_role = event.server.roles.find { |r| r.name =~ /#{name}/i }
        role = LoyaltyRole.upsert!(discord_role)
        role.update!(required_age: required_age.to_i)

        "Synced role #{role.name}"
      else
        discord_role = event.server.create_role
        discord_role.name = name
        role = LoyaltyRole.upsert!(discord_role)
        role.update!(required_age: required_age.to_i)

        "Created role #{role.name}"
      end
    end

    command :deleteloyaltyrole, ADMIN_PERMISSIONS do |event, name|
      role = event.server.loyalty_roles.find_by_name(name)

      unless region
        "Region #{name} not found"
      else
        discord_role = event.server.role(region.id)
        discord_role.delete if discord_role
        region.destroy

        "Removed region #{region.name}"
      end
    end

    server_role_update do |event|
      if LoyaltyRole.exists?(event.role.id)
        LoyaltyRole.upsert!(event.role)
      end
    end

    server_role_delete do |event|
      if LoyaltyRole.exists?(event.id)
        LoyaltyRole.destroy(event.id)
      end
    end

    message do |event|
      CHECK_AND_ADD_ROLE.call(event)
    end
  end
end
