require 'level'
require 'ftor'
class DemoLevel < Level
  def setup
    @electrons = []
    @atoms = []
    4.times do
      atom = create_actor :atom, :x => 40+rand(600), :y => 40+rand(600)
      atom.when :freed_electron do |e|
        @electrons << e
      end
      @atoms << atom
    end

    @stars = []
    20.times { @stars << Ftor.new(rand(viewport.width),rand(viewport.height)) }
  end

  def update(time)
    
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
    @director.update time
  end

  def draw(target, x_off, y_off)
    target.fill [25,25,25,255]
    for star in @stars
      target.draw_circle_s([star.x,star.y],1,[255,255,255,255])
    end
  end
end

