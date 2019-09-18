#################################################################
# Methods for drawing fun runes                                 #
#################################################################

module Alchemy
  ###
  # Draw fancy rune
  #
  # Required Args:
  #  - canvas
  #  - working_width
  #  - origin
  #
  # Optional Args:
  #  - initial_offset
  #  - stroke_color
  #  - rune_char
  #  - font_path
  #
  ###
  def self.draw_rune options={}
    # Break out the variables we'll need from our options
    canvas = options[:canvas]
    working_width = options[:working_width]
    origin = options[:origin]
    stroke_color = options[:stroke_color]
    stroke_color = @default_stroke_color if not options[:stroke_color]
    initial_offset = options[:initial_offset]
    initial_offset = 0 if not initial_offset
    rune_char = options[:rune_char]
    font_path = options[:font_path]
    if not rune_char
      rune_char, font_path = @rune_chars.sample(1)[0]
    end

    # Calculate font size and character height
    font_size = working_width * 0.8

    # Draw text on canvas
    canvas.g.rotate(initial_offset, origin[0], origin[1]) do | shapes |
      shapes.styles(
        :stroke_opacity => 0.0,
      )
      shapes.text(origin[0], origin[1]) do | title |
        title.tspan(
          rune_char
        ).styles(
          :font => font_path,
          :fill => stroke_color,
          :fill_opacity => 1.0,
          :text_anchor => 'middle',
          :baseline_shift => '50%',
          :font_size => font_size
        )
      end
    end
  end

  # Process an array of fun characters and match them to a font
  def self.prepare_rune_chars
    # Prep a list or rune characters
    @rune_types = [
#      {:name => 'staves',
#       :chars => ["༈", "༆", "༒"]},
      {:name => 'greekish-symbols',
       :chars => ["\u2650", "\u2649", "♆", "♅", "☿", "☦", "Ꮸ", "♆"]},
      {:name => 'swirly-symbols',
      :chars => ["స", "৯", "৬", "ঌ", "ঔ", "ঙ", "১", "৩"]}
    ]
    runes = []
    @rune_types.each { |x| runes += x[:chars] }
    runes.uniq!

    # Get the fonts we have available
    fonts = Dir["#{@font_root}/*.ttf"].sort
    fonts.map! do | font_path |
      file = TTFunk::File.open font_path
      cmap = file.cmap

      chars = {}
      unicode_chars = []

      cmap.tables.each do |subtable|
        next if !subtable.unicode?
        chars = chars.merge( subtable.code_map )
      end
      unicode_chars = chars.keys.map{ |dec| dec.chr('UTF-8') }
      [font_path, unicode_chars]
    end

    # Process our runes and attempt to match them up to a font
    results = []
    runes.each do | rune_char |
      fonts.each do | font_path, unicode_chars |
        if unicode_chars.include? rune_char
          results << [rune_char, font_path]
          break
        end
      end
    end

    return results
  end

  @rune_chars = prepare_rune_chars
end
