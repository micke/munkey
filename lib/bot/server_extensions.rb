# frozen_string_literal: true

module ServerExtensions
  def model
    @model ||= Server.upsert!(self)
  end

  delegate :regions, to: :model
  delegate :loyalty_roles, to: :model
end

Discordrb::Server.include(ServerExtensions)
