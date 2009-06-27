require 'level'
require 'ftor'
class DemoLevel < Level
  def setup
    puts "starting level..."
    @electrons = []
    @atoms = []
    @score = create_actor :score, :x => 10, :y => 10
    sound_manager.play_music :background
    5.times do
      atom = create_actor :atom, :x => 40+rand(900), :y => 40+rand(700)
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
        fire :next_level 
        puts "victory!!"
        #@sound_manager.play_sound :victory
      end
      if !@electrons.empty?
        fire :restart_level 
        puts "failed; extra electrons!"
        #@sound_manager.play_sound :failed
      end
    elsif non_inert_atoms.size == 1
      if !@electrons.empty?
        fire :restart_level 
        puts "failed; only one atom left!"
        #@sound_manager.play_sound :failed
      end
    end
  end

  def draw(target, x_off, y_off)
    target.fill [25,25,25,255]
    for star in @stars
      target.draw_circle_s([star.x,star.y],1,[255,255,255,255])
    end
  end
end

