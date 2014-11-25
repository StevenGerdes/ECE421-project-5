class SimpleEvent
  def initialize
    @event_blocks = Array.new
  end

  #sets methods to be called when event is fired
  def listen(&block)
    @event_blocks.push(block)
  end

  #launches methods tied to this event
  def fire(*args)
    @event_blocks.each { |block| block.call(*args) }
  end

end