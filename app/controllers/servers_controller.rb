class ServersController < ApplicationController
  def index
    @servers = Server.all
  end

  def show
    @server = Server.find(params[:id])
  end
end
