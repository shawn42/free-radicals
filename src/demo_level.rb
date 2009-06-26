require 'level'
require 'ftor'
class DemoLevel < Level
  def setup

    10.times do
      create_actor :atom, :x => 40+rand(600), :y => 40+rand(600)
    end

    @stars = []
    20.times { @stars << Ftor.new(rand(@width),rand(@height)) }
  end

  def draw(target, x_off, y_off)
    target.fill [25,25,25,255]
    for star in @stars
      target.draw_circle_s([star.x,star.y],1,[255,255,255,255])
    end
  end
end

