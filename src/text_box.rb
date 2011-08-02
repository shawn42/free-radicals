
class TextBoxView < ActorView
  def draw(target, x_off, y_off, z)
    font = @stage.resource_manager.load_font 'Asimov.ttf', 30
    x = @actor.x
    y = @actor.y
    font.draw @actor.text, x,y,z#, 1,1,target.convert_color([250,250,250,255])
    # OLD
    # font = @stage.resource_manager.load_font 'Asimov.ttf', @actor.size
    # text_image = font.render @actor.text, true, [250,250,250,@actor.alpha]
    # 
    # text_image.blit target.screen, [@actor.x,@actor.y]
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
