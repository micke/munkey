class BotsController < ApplicationController
  def stop
    BOT.stop(false)

    redirect_back fallback_location: root_path
  end

  def run
    BOT.run(true)

    redirect_back fallback_location: root_path
  end
end
