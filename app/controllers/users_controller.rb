class UsersController < ApplicationController
  def index
    locals users: User.all
  end
end
