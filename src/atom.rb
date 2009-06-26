require 'actor'
require 'actor_view'
require 'ftor'

class AtomView < ActorView
  def draw(target, x_off, y_off)
    target.draw_circle_s [@actor.x,@actor.y], @actor.nucleus_size, [240,45,45,255]
    target.draw_circle [@actor.x,@actor.y], @actor.shell_distance, [40,5,245,255]
  end
end

class Atom < Actor

  attr_accessor :nucleus_size, :shell_distance
  def setup
    @nucleus_size = 15
    @shell_distance = 30

    electron_count = rand(9)+1
    electron_count.times do |i|
      shell = get_shell_for_electron(i+1)

      vec = Ftor.new @shell_distance*shell, 0
      rads = deg_to_rads(rand(359))
      vec.rotate!(rads)
      spawn :electron, :x => x+vec.x, :y => y+vec.y, :shell => shell
    end
  end

  def deg_to_rads(deg)
    deg * 3.14 / 180.0
  end

  def get_shell_for_electron(nth)
    # TODO finish
    1
  end


end
