require 'actor'
require 'actor_view'
require 'ftor'
require 'publisher'

class AtomView < ActorView
  NUCLEUS_COLOR = [240,45,45,255]
  INERT_NUCLEUS_COLOR = [225,225,225,155]
  SHELL_COLOR = [40,5,245,255]
  CHARGING_COLOR = [240,245,245,55]
  def draw(target, x_off, y_off)
    target.draw_circle_s [@actor.x,@actor.y], @actor.nucleus_size, NUCLEUS_COLOR
    target.draw_circle_s [@actor.x,@actor.y], @actor.nucleus_size, INERT_NUCLEUS_COLOR if @actor.inert?
    
    @actor.shell_count.times do |i|
      target.draw_circle [@actor.x,@actor.y], @actor.shell_distance*(i+1), SHELL_COLOR
    end
    
    if @actor.charging?
      target.draw_circle_s [@actor.x,@actor.y], @actor.charge*0.03, CHARGING_COLOR
    end
  end
end

class Atom < Actor
  extend Publisher
  attr_accessor :nucleus_size, :shell_distance, :shell_count, :charge
  has_behaviors :updatable
  can_fire :freed_electron
  
  def setup
    @nucleus_size = 15
    @shell_distance = 30
    @shell_count = 0
    @charge = 0

    input_manager.reg MouseDownEvent, :left do |evt|
      start_charging if point_hits? evt.pos[0], evt.pos[1]
    end

    input_manager.reg MouseUpEvent, :left do |evt|
      discharge(evt.pos[0],evt.pos[1]) if charging?
    end

    @electrons = {}
    electron_count = rand(30)+1
    electron_count.times do |i|
      add_electron
    end
  end
  
  def charging?
    @charging
  end
  
  def add_electron(el=nil)
    
    shell = get_shell_for_next_electron
    @shell_count = shell if shell > @shell_count
  
    rads = deg_to_rads(rand(359))
    ex = @shell_distance * shell * Math.cos(rads)
    ey = @shell_distance * shell * Math.sin(rads)

    if el.nil?
      el = spawn :electron, :x => x+ex, :y => y+ey, :shell => shell, :nucleus => self
    else
      el.x = x+ex
      el.y = y+ey
      el.shell = shell
      el.nucleus = self
    end

    @electrons[shell] ||= []
    @electrons[shell] << el
    update_inertness
  end
  
  def update_inertness
    if @electrons[1].nil?
      @inert = false
      return
    end
    if @shell_count == 1 && @electrons[1].size == 2
      fire :inert unless @inert
      @inert = true
    elsif @electrons[@shell_count].size == 8
      fire :inert unless @inert
      @inert = true
    else
      @inert = false
    end
  end
  
  def start_charging
    @charge = 0
    @charging = true
    play_sound :atom_charge
  end
  
  def discharge(dx, dy)
    @charging = false
    
    # discharge the closes electron to the mouse up
    el = nil
    min_dist = 99_999
    last_shell = @shell_count
    @electrons[last_shell].each do |e|
      dist = (dx-e.x)*(dx-e.x)+(dy-e.y)*(dy-e.y)
      if dist < min_dist
        el = e
        min_dist = dist
      end
    end
    @electrons[last_shell].delete el
    @shell_count -= 1 if @electrons[last_shell].empty?
    update_inertness
    
    stop_sound :atom_charge
    el.free Ftor.new(dx-x,dy-y)
    puts "[#{self.object_id}] freeing electron [#{el.object_id}]"
    fire :freed_electron, el
  end

  # TODO move this to common place
  def deg_to_rads(deg)
    deg * Math::PI / 180.0
  end

  def get_shell_for_next_electron
    nth = @electrons.collect{|k,v|v.size}.inject(0) { |s,v| s += v }+1
    if nth < 3
      return 1
    elsif nth < 11
      return 2
    elsif nth < 29
      return 3
    elsif nth < 61
      return 4
    else
      puts "whoa that's too many electrons!!!"
      return 5
    end
  end
  
  def point_hits?(px, py)
    diff_x = px-x
    diff_y = py-y
    dist = diff_x*diff_x+diff_y*diff_y
    
    # TODO hard coded to first shell
    dist.abs <= shell_count*@shell_distance*@shell_distance*shell_count
  end
  
  def inert?
    @inert
  end
  
  def update(time)
    if charging?
      max_charge = @shell_count*1000
      @charge += time
      @charge = max_charge if @charge > max_charge
    end
  end

  # returns true if the atom claims the electron
  def attract(el)
    return if inert?
    if point_hits? el.x, el.y
      add_electron el
      puts "[#{self.object_id}] adding electron [#{el.object_id}]"
      play_sound :electron_freed
      return true
    else
      dx = @x-el.x
      dy = @y-el.y
      
      dist = Math.sqrt(dx*dx+dy*dy)
      f = Ftor.new(dx,dy)/dist.to_f/100.0
      el.force += f
    end
    false
  end

end
