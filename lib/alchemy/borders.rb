#################################################################
# Methods for drawing borders around our alchemy circles        #
#################################################################

module Alchemy
  ###
  # Draw a border for our circle
  #
  # Required Args:
  #  - canvas
  #  - origin
  #  - working_width
  #
  # Optional Args:
  #  - stroke_width
  #  - stroke_color
  #  - point_count
  #  - runes_around_border
  #  - zig_zag_around_border
  #  - blank_space_around_border
  #
  ###

  def self.draw_border options={}
    # Break out the variables we'll need from our options
    canvas = options[:canvas]
    origin = options[:origin]
    working_width = options[:working_width]
    point_count = options[:point_count]
    point_count = 8 if not options[:point_count]
    stroke_width = options[:stroke_width]
    stroke_width = @default_stroke_width if not stroke_width
    stroke_color = options[:stroke_color]
    stroke_color = @default_stroke_color if not stroke_color
    runes_around_border = options[:runes_around_border]
    runes_around_border = @default_runes_around_border if not runes_around_border
    zig_zag_around_border = options[:zig_zag_around_border]
    zig_zag_around_border = @default_zig_zag_around_border if not zig_zag_around_border
    blank_space_around_border = options[:blank_space_around_border]
    blank_space_around_border = @default_blank_space_around_border if not blank_space_around_border
    inner_circle_distance = 0.05 # How far is our inner circle from our outer one?

    ###
    # Draw our container circle(s)
    ###

    # Draw our outer circle
    draw_circle(
      :canvas => canvas,
      :radius => working_width / 2,
      :origin => origin
    )
    working_width -= stroke_width * 2

    if runes_around_border or zig_zag_around_border or blank_space_around_border
      # Draw some ziggy-zaggies between our inner and outer border rings
      if zig_zag_around_border
        0.upto(point_count).each do | i |
          draw_polygon(
            :canvas => canvas,
            :working_width => working_width,
            :origin => origin,
            :point_count => 12,
            :initial_offset => (360 / point_count) * i,
          )
        end
      end

      # Draw dope runes around our border
      if runes_around_border
        # Adjust our inner border circle distance
        inner_circle_distance = 0.1

        # Generate rando text to fill out the circle
        rune_text = BetterLorem.p(10, true, true).gsub(/[^a-z ]/, '')
        rune_text = rune_text.split(" ").select { |x| x.length >= 4 }
        rune_text = rune_text.join " "
        rune_length = 180
        rune_text = rune_text.slice 0, rune_length
        font_size = (working_width * inner_circle_distance) / 2
        font_path = "#{@font_root}/heron.ttf"
        font_size *= 0.8

        # Draw text on canvas
        0.upto(360 - 1).each do | i |
          break if i == rune_text.length

          # Set the rotation angle
          rotation_angle = (360 / rune_text.length) * i

          # Calcualte the end point given our distance from the center point
          line_length = working_width / 2
          line_length -= font_size / 2
          line_length -= font_size * 0.15
          x2 = origin[0] + (line_length * Math.cos(rotation_angle * (Math::PI / 180)))
          y2 = origin[1] + (line_length * Math.sin(rotation_angle * (Math::PI / 180)))

          # Draw Text
          canvas.g.rotate(90 + rotation_angle, x2, y2) do | shapes |
            shapes.styles(
              :fill => stroke_color,
              :stroke_opacity => 0.0,
            )
            shapes.text(x2, y2) do | title |
              title.tspan(
                rune_text[i]
              ).styles(
                :font => font_path,
                :text_anchor => 'middle',
                :baseline_shift => '50%',
                :font_size => font_size,
                :font_weight => 100,
              )
            end
          end
        end
      end

      # Draw our inner circle
      working_width -= working_width * inner_circle_distance
      draw_circle(
        :canvas => canvas,
        :radius => working_width / 2,
        :origin => origin,
      )
      working_width -= stroke_width * 2
    end

    return working_width
  end
end
