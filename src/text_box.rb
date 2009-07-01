require 'actor'
require 'actor_view'

class TextBoxView < ActorView
  def draw(target, x_off, y_off)
    font = @mode.resource_manager.load_font 'Asimov.ttf', @actor.size
    text_image = font.render @actor.text, true, [250,250,250,@actor.alpha]

    text_image.blit target.screen, [@actor.x,@actor.y]
  end
end

class TextBox < Actor
  attr_accessor :text, :alpha, :size
  
  def setup
    @text = @opts[:text]
    @alpha = @opts[:alpha]
    @size = @opts[:size]
    @alpha ||= 255
    @size ||= 30
  end
end
