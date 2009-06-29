require 'actor'
require 'actor_view'

class TextBoxView < ActorView
  def draw(target, x_off, y_off)
    font = @mode.resource_manager.load_font 'Asimov.ttf', 30
    text_image = font.render @actor.text, true, [250,250,250,255]

    text_image.blit target.screen, [@actor.x,@actor.y]
  end
end

class TextBox < Actor
  attr_accessor :text
  
  def setup
    @text = @opts[:text]
  end
end
