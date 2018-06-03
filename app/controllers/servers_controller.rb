class ServersController < ApplicationController
  def index
    @servers = Server.all
  end

  def show
    @server = server
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
