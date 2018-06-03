module Bot
  module Regions
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    command :regions do |event|
      event << "Regions:"
      event.server.regions.order(:name).all.each do |role|
        event << ".#{role.name.downcase}"
      end

      event << ""
      event << "To get a role just reply with the role, your message will be deleted when you get the role."
      event << "Example; .#{event.server.regions.first&.name&.downcase || "stockholm"}"
    end

    command :createregion, ADMIN_PERMISSIONS do |event, name|
      next if event.server.regions.exists?(name: name)
      discord_role = event.server.create_role
      discord_role.name = name
      region = event.server.regions.create!(name: name, discord_id: discord_role.id)

      "Created region #{region.name}"
    end

    command :removeregion, ADMIN_PERMISSIONS do |event, name|
      region = event.server.regions.find_by_name(name)

      unless region
        "Region #{name} not found"
      else
        discord_role = event.server.role(region.discord_id)
        discord_role.delete if discord_role
        region.destroy

        "Removed region #{region.name}"
      end
    end

    command :renameregion, ADMIN_PERMISSIONS do |event, name, new_name|
      region = event.server.regions.find_by_name(name)

      unless region
        "Region #{name} not found"
      else
        discord_role = event.server.role(region.discord_id)
        discord_role.name = new_name
        region.update!(name: new_name)

        "Renamed region #{region.name}"
      end
    end

    message start_with: "." do |event|
      if event.message.content =~ /\.(.+)/
        if role = event.server.regions.where(name: $1).first
          # Remove other region regions
          existing_region_roles = event.user.roles.collect(&:id) & event.server.regions.pluck(:discord_id)

          # Add new region role
          event.user.modify_roles(role.discord_id, existing_region_roles)
          event.message.delete
        end
      end
    end
  end
end
