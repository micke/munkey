# frozen_string_literal: true

class ApplicationController < ActionController::Base
  private

  def locals(action = nil, hash)
    render action: action, locals: hash
  end
end
