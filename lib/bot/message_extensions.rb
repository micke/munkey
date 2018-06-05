# frozen_string_literal: true

module MessageExtensions
  def embedded_images
    embeds.select { |e| e.type == :image }.collect { |e| e.url }
  end

  def attached_images
    attachments.select { |a| a.image? }.collect { |a| a.url }
  end

  def all_images
    embedded_images | attached_images
  end
end

Discordrb::Message.include(MessageExtensions)
