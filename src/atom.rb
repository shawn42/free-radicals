require 'actor'
require 'actor_view'
require 'ftor'

class AtomView < ActorView
  def draw(target, x_off, y_off)
    target.draw_circle_s [@actor.x,@actor.y], @actor.nucleus_size, [240,45,45,255]
    target.draw_circle [@actor.x,@actor.y], @actor.shell_distance, [40,5,245,255]
    
    if @actor.charging?
      target.draw_circle_s [@actor.x,@actor.y], @actor.charge*0.03, [240,245,245,155]
    end
  end
end

class Atom < Actor

  attr_accessor :nucleus_size, :shell_distance, :charge
  has_behaviors :updatable
  
  def setup
    @nucleus_size = 15
    @shell_distance = 30
    @shell_count = 0
    @charge = 0

    input_manager.reg MouseDownEvent, :left do |evt|
      start_charging if point_hits? evt.pos[0], evt.pos[1]
    end

    input_manager.reg MouseUpEvent, :left do |evt|
      discharge if charging?
    end

    electron_count = rand(9)+1
    electron_count.times do |i|
      shell = get_shell_for_electron(i+1)
      @shell_count = shell if shell > @shell_count
      vec = Ftor.new @shell_distance*shell, 0
      rads = deg_to_rads(rand(359))
      vec.rotate!(rads)
      spawn :electron, :x => x+vec.x, :y => y+vec.y, :shell => shell
    end
  end
  
  def charging?
    @charging
  end
  
  def start_charging
    puts "charging..."
    @charge = 0
    @charging = true
  end
  
  def discharge
    puts "ZAP [#{@charge}]"
    @charging = false
    # TODO send electrons flying
  end

  def deg_to_rads(deg)
    deg * 3.14 / 180.0
  end

  def get_shell_for_electron(nth)
    # TODO finish
    1
  end
  
  def point_hits?(px, py)
    diff_x = px-x
    diff_y = py-y
    dist = diff_x*diff_x+diff_y*diff_y
    
    # TODO hard coded to first shell
    dist.abs <= @shell_distance*@shell_distance
  end
  
  def update(time)
    if charging?
      max_charge = @shell_count*1000
      @charge += time
      @charge = max_charge if @charge > max_charge
    end
  end


end
