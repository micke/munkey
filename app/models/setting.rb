# frozen_string_literal: true

class Setting < ActiveRecord::Base
  serialize :value
end
