# frozen_string_literal: true

class MonitorsController < ApplicationController
  def run
    MONITORING_TASK.execute
    redirect_back fallback_location: root_path
  end

  def stop
    MONITORING_TASK.shutdown
    redirect_back fallback_location: root_path
  end
end
