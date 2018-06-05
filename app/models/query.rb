# frozen_string_literal: true

class Query
  attr_reader :advanced, :want, :user, :query

  def initialize(advanced:, want:, user:, query:)
    @advanced = advanced
    @want = want
    @user = user
    @query = query
  end
end
