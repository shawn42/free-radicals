require 'actor'
require 'actor_view'
require 'ftor'

class ElectronView < ActorView
  def draw(target, x_off, y_off)
    target.draw_circle_s [@actor.x,@actor.y], @actor.radius, [40,225,25,255]
    target.draw_circle_s [@actor.x,@actor.y], @actor.radius+3, [20,255,20,155]
  end
end

class Electron < Actor

  has_behaviors :updatable, :layered => 2

  attr_accessor :radius, :nucleus, :shell, :force, :bounced
  
  def setup
    @nucleus = @opts[:nucleus]
    self.shell = @opts[:shell]
    @speed = 90
    @radius = 3
    @force = Ftor.new 0, 0
  end
  
  def shell=(new_shell)
    @speed_deg = 90+rand(90)
    @shell = new_shell
  end
  
  def free(force)
    @force = Ftor.new(@x-@nucleus.x, @y-@nucleus.y)
    @force.m = force.m*0.1
    @nucleus = nil
    @shell = nil
    play_sound :electron_freed
  end
  
  def update(time)
    if @nucleus.nil?
      dir_vec = @force * @speed * (time/1000.0)
      @x += dir_vec.x
      @y += dir_vec.y
      
      
      # hardcode the borders for now
      if !bounced && (@x <= 0 || @x >= 1024)
        play_sound :electron_freed
        @force *= 0.6
        @force = Ftor.new(-@force.x,@force.y)
        @bounced = true
      elsif !bounced && (@y <= 0 || @y >= 800)
        play_sound :electron_freed
        @force *= 0.6
        @force = Ftor.new(@force.x,-@force.y)
        @bounced = true
      end
      @bounced = false if @y > 0 && @y < 800 && @x > 0 && @x < 1024
      
    else
      # follow shell
      movement_deg = @speed_deg * (time/1000.0)
      dx = x-@nucleus.x
      dy = y-@nucleus.y
      rads = Math.atan(dy.to_f/dx)
      
      if dx < 0
        rads += Math::PI
      end
      
      movement_rads = deg_to_rads movement_deg
      rads = movement_rads+rads
      
      ex = @nucleus.shell_distance * @shell * Math.cos(rads)
      ey = @nucleus.shell_distance * @shell * Math.sin(rads)
      @x = ex+@nucleus.x
      @y = ey+@nucleus.y
        
    end
  end
  
  def deg_to_rads(deg)
    deg * Math::PI / 180.0
  end
  
  def rads_to_degs(rads)
    rads * 180.0 / Math::PI
  end

end
