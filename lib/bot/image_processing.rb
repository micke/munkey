require_relative "../image_recognition"

module Bot
  module ImageProcessing
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer

    message in: "visa-din-keeb" do |event, *args|
      next unless ImageRecognition.available?
      images = event.message.all_images

      if images.any?
        description_message = event.send_message "Analyzing..."
        image_recognition = ImageRecognition.new(images)

        if image_recognition.has_keeb_image?
          event.channel.free_up_pin
          event.message.pin
        end

        description_message.delete
      end
    end
  end
end
