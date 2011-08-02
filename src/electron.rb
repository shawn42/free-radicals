
class ElectronView < ActorView
  def draw(target, x_off, y_off, z)
    target.draw_circle @actor.x,@actor.y, @actor.radius, [40,225,25,255], z
    target.draw_circle @actor.x,@actor.y, @actor.radius+3, [20,255,20,155], z
  end
end

class Electron < Actor

  has_behaviors :updatable, :audible, :layered => 2

  attr_accessor :radius, :nucleus, :shell, :force
  
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
    @force = Ftor.new(self.x-@nucleus.x, self.y-@nucleus.y)
    @force.m = force.m*0.1
    @nucleus = nil
    @shell = nil
    play_sound :electron_freed
  end
  
  def update(time)
    if @nucleus.nil?
      dir_vec = @force * @speed * (time/1000.0)
      self.x += dir_vec.x
      self.y += dir_vec.y
      
      
      # hardcode the borders for now
      if self.x <= 0  
        play_sound :electron_freed
        @force *= 0.6
        self.x = -self.x
        @force = Ftor.new(-@force.x,@force.y)
      elsif self.x >= 1024
        play_sound :electron_freed
        @force *= 0.6
        self.x -= self.x-1024
        @force = Ftor.new(-@force.x,@force.y)
      elsif self.y <= 0 
        play_sound :electron_freed
        @force *= 0.6
        self.y = -self.y
        @force = Ftor.new(@force.x,-@force.y)
      elsif self.y >= 800
        play_sound :electron_freed
        @force *= 0.6
        self.y -= self.y-800
        @force = Ftor.new(@force.x,-@force.y)
      end
      
    else
      # follow shell
      movement_deg = @speed_deg * (time/1000.0)
      dx = self.x-@nucleus.x
      dy = self.y-@nucleus.y
      rads = Math.atan(dy.to_f/dx)
      
      if dx < 0
        rads += Math::PI
      end
      
      movement_rads = deg_to_rads movement_deg
      rads = movement_rads+rads
      
      ex = @nucleus.shell_distance * @shell * Math.cos(rads)
      ey = @nucleus.shell_distance * @shell * Math.sin(rads)
      self.x = ex+@nucleus.x
      self.y = ey+@nucleus.y
        
    end
  end
  
  def deg_to_rads(deg)
    deg * Math::PI / 180.0
  end
  
  def rads_to_degs(rads)
    rads * 180.0 / Math::PI
  end

end
