
class AtomView < ActorView
  NUCLEUS_COLORS = [[240,45,45,255],[240,45,245,255],[40,45,245,255],[240,245,0,255]]
  INERT_NUCLEUS_COLOR = [0,0,0,155]
  NUCLEUS_COLOR = [25,25,25,155]
  SHELL_COLOR = [40,5,245,255]
  CHARGING_COLOR = [240,245,245,55]
  def draw(target, x_off, y_off, z)
    if @nucleus_parts.nil?
      @nucleus_parts = []
      deg = rand(359)
      5.times do
        c = NUCLEUS_COLORS[rand(NUCLEUS_COLORS.size)]
        rads = @actor.deg_to_rads(deg)
        size = @actor.nucleus_size*0.4
        ex = size * Math.cos(rads)
        ey = size * Math.sin(rads)
        @nucleus_parts << [ex,ey,c]
        deg = deg+50+rand(30)
      end
    end
    @nucleus_parts.each do |np|
      target.draw_circle @actor.x+np[0], @actor.y+np[1], @actor.nucleus_size*0.7, np[2], z
    end
    
    @actor.shell_count.times do |i|
      target.draw_circle @actor.x,@actor.y, @actor.shell_distance*(i+1), SHELL_COLOR, z
    end
    target.draw_circle @actor.x,@actor.y, @actor.nucleus_size*1.2, NUCLEUS_COLOR, z
    target.draw_circle @actor.x,@actor.y, @actor.shell_distance*@actor.shell_count+2, INERT_NUCLEUS_COLOR, z if @actor.inert?
    
    if @actor.charging?
      target.draw_circle @actor.x,@actor.y, @actor.charge*0.03, CHARGING_COLOR, z
    end
    
    # @font ||= @stage.resource_manager.load_font 'Asimov.ttf', 30
    # text_image = @font.render @actor.outer_shell_label, true, [250,250,250,255]
    # text_image.blit target.screen, [@actor.x-0.5*@actor.nucleus_size,@actor.y-0.5*@actor.nucleus_size]
  end
end

class Atom < Actor
  extend Publisher
  attr_accessor :nucleus_size, :shell_distance, :shell_count, :charge
  has_behaviors :updatable, :audible
  can_fire :freed_electron
  
  INERT_ELEMENTS = {
    2 => 'helium',
    10 => 'neon',
    18 => 'argon',
    36 => 'krypton',
    54 => 'xenon',
    86 => 'radon',
    118 => 'ununoctium'
  }
  
  INERT_ELEMENT_SYMBOLS = {
    2 => 'He',
    10 => 'Ne',
    18 => 'Ar',
    36 => 'Kr',
    54 => 'Xe',
    86 => 'Rn',
    118 => 'Uuo'
  }
  
  def setup
    @nucleus_size = 18
    @shell_distance = 30
    @shell_count = 0
    @charge = 0

    # TODO unregister when I go inert
    input_manager.reg :mouse_down, MsLeft do |evt|
      unless inert? || electron_count == 1
        pos = evt[:data]
        start_charging if point_hits? pos[0], pos[1]
      end
    end

    input_manager.reg :mouse_up, MsLeft do |evt|
      unless inert? || electron_count == 1
        pos = evt[:data]
        discharge(pos[0],pos[1]) if charging?
      end
    end

    @electrons = {}
    @opts[:electrons].times do |i|
      add_electron
    end
  end
  
  def outer_shell_label
    if inert?
      INERT_ELEMENT_SYMBOLS[electron_count]
    else
      case @shell_count
      when 1
        if @electrons[@shell_count].size == 1
          "+1"
        end
      else
        "#{@electrons[@shell_count].size}"
      end
    end
  end
  
  def electron_count
    count = @electrons.collect{|k,v|v.size}.inject(0) { |s,v| s += v }
    count.nil? ? 0 : count
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
    if @electrons[1].nil? or @electrons[@shell_count].nil?
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
    # play_sound :atom_charge
  end
  
  def discharge(dx, dy)
    @charging = false
    
    # discharge the closes electron to the mouse up
    el = nil
    min_dist = 999_999
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
    
    # stop_sound :atom_charge
    el.free Ftor.new(el.x-x,el.y-y).normal*@charge*0.1
    fire :freed_electron, el
  end

  # TODO move this to common place
  def deg_to_rads(deg)
    deg * Math::PI / 180.0
  end

  def get_shell_for_next_electron
    nth = electron_count+1
    if nth < 3
      return 1
    elsif nth < 11
      return 2
    elsif nth < 29
      return 3
    elsif nth < 61
      return 4
    elsif nth < 79
      return 5
    elsif nth < 111
      return 6  
    elsif nth < 119
      return 7
    else
      return 8
    end
  end
  
  def point_hits?(px, py)
    diff_x = px-x
    diff_y = py-y
    dist = diff_x*diff_x+diff_y*diff_y
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
    if inert?
      dx = x-el.x
      dy = y-el.y
    
      dist = Math.sqrt(dx*dx+dy*dy)
      f = Ftor.new(dx,dy)/dist.to_f/100.0
      # repel a little, too much makes it weird at the end when most atoms are inert
      el.force += f*-0.1*electron_count
      return false
    else
      if point_hits? el.x, el.y
        add_electron el
        play_sound :electron_freed
        return true
      else
        dx = x-el.x
        dy = y-el.y
      
        dist = Math.sqrt(dx*dx+dy*dy)
        f = Ftor.new(dx,dy)/dist.to_f/100.0
        el.force += f
        el.force += f*0.2*electron_count
      end
      false
    end
  end

end
