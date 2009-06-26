require 'actor'
require 'actor_view'

class ElectronView < ActorView
  def draw(target, x_off, y_off)
    target.draw_circle_s [@actor.x,@actor.y], @actor.radius, [40,225,25,255]
  end
end

class Electron < Actor

  has_behaviors :layered => 2

  attr_accessor :radius
  def setup
    @radius = 3
  end

end
