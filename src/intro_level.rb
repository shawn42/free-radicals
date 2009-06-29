require 'level'
require 'ftor'
class IntroLevel < Level
  def setup
    puts "starting level..."
    @electrons = []
    @atoms = []
    sound_manager.play_music :background
    level_def = {}
    level_def[:atoms] = []
    atom_def = {:x => 100,:y=>200,:electrons=>3}
    level_def[:atoms] << atom_def
    level_def[:atoms].each do |atom_def|
      atom = create_actor :atom, :x => atom_def[:x], :y => atom_def[:y], :electrons => atom_def[:electrons]
      atom.when :freed_electron do |e|
        @electrons << e
      end
      @atoms << atom
    end
    
    @atoms.first.when :inert do
      @intros.first.each do |i|
        i.hide
      end
      
      @intros[1].each do |i|
        i.show
      end
      
      @atoms.first.input_manager.reg KeyDownEvent do 
        @atoms.first.input_manager.clear_hooks
        fire :next_level
      end
    end
    
    
    @intros = []
    first = []
    first << create_actor(:text_box, :x => 200, :y => 50, :text => 'Welcome to Free Radicals')
    first << create_actor(:text_box, :x => 200, :y => 150, :text => 'Help me make these atoms inert')
    first << create_actor(:text_box, :x => 200, :y => 200, :text => 'Inert atoms have 2 electrons in their outer shell')
    first << create_actor(:text_box, :x => 200, :y => 300, :text => 'Shoot the extra electon off this Helium atom')
    first << create_actor(:text_box, :x => 200, :y => 350, :text => 'by clicking and holding on the atom')
    @intros << first

    second = []
    second << create_actor(:text_box, :hide => true, :x => 200, :y => 100, :text => 'Great shot!')
    second << create_actor(:text_box, :hide => true, :x => 200, :y => 150, :text => 'But we cannot have extra electrons floating around!')
    second << create_actor(:text_box, :hide => true, :x => 200, :y => 200, :text => 'Larger inert atoms need 8 electrons in their outer shell')
    second << create_actor(:text_box, :hide => true, :x => 200, :y => 300, :text => 'Atoms attract electrons if they need them')
    second << create_actor(:text_box, :hide => true, :x => 200, :y => 350, :text => 'but repel them if they are not needed')
    second << create_actor(:text_box, :hide => true, :x => 200, :y => 450, :text => 'The outer electron closest to the cursor will be freed.')

    second << create_actor(:text_box, :hide => true, :x => 280, :y => 550, :text => 'Press any key to continue.')
    @intros << second


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

