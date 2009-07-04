require 'level'
require 'ftor'
class DemoLevel < Level
  attr_accessor :score
  def setup
    @electrons = []
    @atoms = []
    @score = create_actor :score, :x => 10, :y => 10

    sound_manager.play_music :background
    
    prev_level = @opts[:prev_level]
    @score += prev_level.score.score if prev_level && prev_level.respond_to?(:score)
    
    input_manager.reg KeyDownEvent, K_R do
      fire :restart_level
      input_manager.clear_hooks self
    end
    
    # TODO how does one correctly extend ResourceManager?
    level_def = YAML::load_file(LEVEL_PATH+@opts[:level_file])
    @time_left = create_actor :time_left, :x => 610, :y => 10
    time = level_def[:time]
    time ||= 60_000
    @time_left += time.to_i
        
    create_actor(:text_box, :x => 500, :y => 350, :alpha => 50, :size => 50, :text => level_def[:name]) if level_def[:name]
    create_actor(:text_box, :x => 500, :y => 450, :alpha => 50, :size => 20, :text => "by: "+level_def[:author]) if level_def[:author]
    level_def[:atoms].each do |atom_def|
      atom = create_actor :atom, :x => atom_def[:x], :y => atom_def[:y], :electrons => atom_def[:electrons]
      atom.when :freed_electron do |e|
        @electrons << e
      end
      
      atom.when :inert do 
        @score.score += 10
      end
      @atoms << atom
    end

    @stars = []
    20.times { @stars << Ftor.new(rand(viewport.width),rand(viewport.height)) }
  end

  def update(time)
    @time_left -= time
    
    @director.update time
    # apply attraction forces to freed electrons
    @electrons.each do |e|
      @atoms.each do |a|
        claimed = a.attract e
        if claimed
          @electrons.delete e
          break
        end
      end
    end
    
    # win - lose conditions
    non_inert_atoms = @atoms.select{|a|!a.inert?}
    if non_inert_atoms.size == 0
      if @electrons.empty?
        puts "victory!!"
        @sound_manager.play_sound :victory
        fire :next_level 
      end
      if !@electrons.empty?
        puts "failed; extra electrons!"
        @sound_manager.play_sound :defeat
        fire :restart_level
      end
    elsif non_inert_atoms.size == 1
      if @electrons.empty?
        puts "failed; only one atom left!"
        @sound_manager.play_sound :defeat
        fire :restart_level 
      end
    end
    
    
    if @time_left.time_left <= 0
      puts "failed; ran out of time!"
      @sound_manager.play_sound :defeat
      fire :restart_level 
    end
  end

  def draw(target, x_off, y_off)
    target.fill [25,25,25,255]
    for star in @stars
      target.draw_circle_s([star.x,star.y],1,[255,255,255,255])
    end
  end
end

