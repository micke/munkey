class User < ActiveRecord::Base
  has_many :searches

  def self.add(user)
    create!(id: user.id, name: user.username)
  end

  def self.allowed?(user)
    exists?(id: user.id, blocked: false)
  end

  def self.blocked?(user)
    exists?(id: user.id, blocked: true)
  end

  def self.block(user)
    find_or_create_by!(id: user.id)
      .update_with_discord_user(user)
      .update!(blocked: true)
  end

  def self.unblock(user)
    find_or_create_by!(id: user.id)
      .update_with_discord_user(user)
      .update!(blocked: false)
  end

  def searches_count
    searches.count
  end

  def update_with_discord_user(user)
    update!(name: user.username)
    self
  end

  def discord
    @on_discord ||= BOT.users[id]
  rescue RuntimeError
    nil
  end

  delegate :avatar_url, to: :discord, allow_nil: true
end
