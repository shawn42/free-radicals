require 'stage'
require 'ftor'
class DemoStage < Stage
  attr_accessor :score
  def setup
    super
    @electrons = []
    @atoms = []
    @score = create_actor :score, :x => 10, :y => 10

    sound_manager.play_music :background
    
    prev_stage = @opts[:prev_stage]
    @score += prev_stage.score.score if prev_stage && prev_stage.respond_to?(:score)
    
    input_manager.reg KeyDownEvent, K_R do
      fire :restart_stage
      input_manager.clear_hooks self
    end
    input_manager.reg KeyDownEvent, K_RSHIFT do
      fire :next_stage
      sound_manager.play_sound :defeat
      input_manager.clear_hooks self
    end
    
    # TODO how does one correctly extend ResourceManager?
    stage_def = YAML::load_file(LEVEL_PATH+@opts[:stage_file])
    @time_left = create_actor :time_left, :x => 610, :y => 10
    time = stage_def[:time]
    time ||= 60_000
    @time_left += time.to_i
        
    create_actor(:text_box, :x => 500, :y => 350, :alpha => 50, :size => 50, :text => stage_def[:name]) if stage_def[:name]
    create_actor(:text_box, :x => 500, :y => 450, :alpha => 50, :size => 20, :text => "by: "+stage_def[:author]) if stage_def[:author]
    stage_def[:atoms].each do |atom_def|
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
        fire :next_stage 
      end
      if !@electrons.empty?
        puts "failed; extra electrons!"
        @sound_manager.play_sound :defeat
        fire :restart_stage
      end
    elsif non_inert_atoms.size == 1
      if @electrons.empty?
        puts "failed; only one atom left!"
        @sound_manager.play_sound :defeat
        fire :restart_stage 
      end
    end
    
    
    if @time_left.time_left <= 0
      puts "failed; ran out of time!"
      @sound_manager.play_sound :defeat
      fire :restart_stage 
    end
  end

  def draw(target)
    target.fill [25,25,25,255]
    for star in @stars
      target.draw_circle_s([star.x,star.y],1,[255,255,255,255])
    end
    super
  end
end

