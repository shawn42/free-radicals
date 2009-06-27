require 'level'
require 'ftor'
class DemoLevel < Level
  def setup
    @electrons = []
    @atoms = []
    @score = create_actor :score, :x => 10, :y => 10
    sound_manager.play_music :background
    4.times do
      atom = create_actor :atom, :x => 40+rand(600), :y => 40+rand(600)
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
  end

  def draw(target, x_off, y_off)
    target.fill [25,25,25,255]
    for star in @stars
      target.draw_circle_s([star.x,star.y],1,[255,255,255,255])
    end
  end
end

