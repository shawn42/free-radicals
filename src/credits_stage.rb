
class Unicorn < Actor
  has_behaviors :graphical
end
class CreditsStage < Stage
  def setup
    super
    @electrons = []
    @atoms = []
    sound_manager.play_music :background
    stage_def = {}
    stage_def[:atoms] = []
    atom_def = {:x => 100,:y=>200,:electrons=>118}
    stage_def[:atoms] << atom_def
    stage_def[:atoms].each do |atom_def|
      atom = create_actor :atom, :x => atom_def[:x], :y => atom_def[:y], :electrons => atom_def[:electrons]
      atom.when :freed_electron do |e|
        @electrons << e
      end
      @atoms << atom
    end
    
    create_actor :unicorn, :x => 500, :y => 150

    create_actor(:text_box, :x => 400, :y => 250, :text => 'You Win!')
    create_actor(:text_box, :x => 280, :y => 450, :text => 'by Shawn Anderson (shawn42)')
    create_actor(:text_box, :x => 500, :y => 110, :text => '(the unicorn is for jacius)', :size => 20)

    @stars = []
    20.times { @stars << Ftor.new(rand(viewport.width),rand(viewport.height)) }
  end

  def update(time)
    super
    # @director.update time
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
    
   super
  end

  def draw(target)
    target.fill [25,25,25,255]
    for star in @stars
      target.draw_circle_s([star.x,star.y],1,[255,255,255,255])
    end
    super
  end
end

