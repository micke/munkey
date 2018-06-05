# frozen_string_literal: true

class ServersController < ApplicationController
  def index
    locals servers: Server.all
  end

  def show
    locals server: server
  end

  def update_from_discord
    server.update_from_discord!

    redirect_to server
  end

  private

  def server
    @server ||= Server.find(params[:id])
  end
end
