class TimeLeftView < ActorView
  def draw(target,x_off,y_off)
    text = (@actor.time_left/1000.0).ceil.to_s
    text = '0'*(3-text.size)+text

    font = @mode.resource_manager.load_font 'Asimov.ttf', 30
    text_image = font.render text, true, [250,250,250,255]

    x = @actor.x
    y = @actor.y

    text_image.blit target.screen, [x,y]
  end
end
class TimeLeft < Actor
  attr_accessor :time_left

  def setup
    clear
  end

  def clear
    @time_left = 0
  end

  def +(amount)
    @time_left += amount
    self
  end

  def -(amount)
    @time_left -= amount
    self
  end
end
