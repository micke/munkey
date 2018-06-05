# frozen_string_literal: true

class ItemTracker
  def initialize(items)
    @stored_items = Array.new(items)
  end

  def add_and_return_new(items)
    new_items = items.reject { |i| stored_items.include?(i) }
    stored_items.push(*new_items)
    stored_items.sort_by!(&:updated)
    cleanup
    new_items
  end

  private

  attr_reader :stored_items

  def cleanup
    stored_items.shift(stored_items.count - 50) if stored_items.count > 50
  end
end
