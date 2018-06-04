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
      region = Region.upsert!(discord_role)


      "Created region #{region.name}"
    end

    command :removeregion, ADMIN_PERMISSIONS do |event, name|
      region = event.server.regions.find_by_name(name)

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
      if Region.exists?(event.role.id)
        Region.upsert!(event.role)
      end
    end

    server_role_delete do |event|
      if Region.exists?(event.id)
        Region.destroy(event.id)
      end
    end

    message start_with: "." do |event|
      if event.message.content =~ /\.(.+)/
        if role = event.server.regions.where(name: $1).first
          # Remove other region regions
          existing_region_roles = event.user.roles.collect(&:id) & event.server.regions.pluck(:id)

          # Add new region role
          event.user.modify_roles(role.id, existing_region_roles)
          event.message.delete
        end
      end
    end
  end
end
