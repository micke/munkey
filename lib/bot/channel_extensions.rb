module ChannelExtensions
  def free_up_pin
    sorted_pins = pins.sort_by(&:timestamp)

    until sorted_pins.count < 50
      sorted_pins.shift.unpin
    end
  end
end

Discordrb::Channel.include(ChannelExtensions)
