#################################################################
# Random Polygons Circle Generator Methods                      #
#################################################################

module Alchemy
  ###
  # Draw a random polygons circle
  #
  # Required Args:
  #  - canvas
  #  - origin
  #  - working_width
  #
  # Optional Args:
  #  - stroke_width
  #  - stroke_color
  #  - recurse_depth
  #
  ###

  def self.draw_random_polygons_circle options={}
    # Break out the variables we'll need from our options
    canvas = options[:canvas]
    working_width = options[:working_width]
    origin = options[:origin]
    stroke_width = options[:stroke_width]
    stroke_width = @default_stroke_width if not stroke_width
    stroke_color = options[:stroke_color]
    stroke_color = @default_stroke_color if not stroke_color
    recurse_depth = options[:recurse_depth]
    recurse_depth = rand(5..10) if not recurse_depth

    # Draw our starter polygon
    point_count = rand(5..16)
    draw_polygon(
      :canvas => canvas,
      :working_width => working_width,
      :origin => origin,
      :point_count => point_count,
      :connect_to_center => true
    )

    # Draw our next polygon
    border_circles_drawn = false
    border_circle_radius = (working_width * 0.1) / 2
    0.upto(recurse_depth - 1).each do | i |
      # Draw a circle right before we draw our last couple sahpes
      if i == recurse_depth - 2 and false
        draw_circle(
          :canvas => canvas,
          :origin => origin,
          :radius => working_width / 2,
          :styles => {:fill_opacity => 0.0}
        )
      end

      # Set point count
      old_point_count = point_count
      base_range = (4..10 + recurse_depth).to_a
      base_range = (3..15).to_a
      while old_point_count ==  point_count or (point_count % 2 != old_point_count % 2)
        point_count = base_range.sample(1)[0] - i
        point_count = old_point_count if point_count == 7
        point_count = 3 if point_count < 3
      end

      # Draw a circle if we're three or less steps out and the RNGesus says to do so
      if i >= recurse_depth-3 and rand(1..3) == 1
        draw_circle(
          :canvas => canvas,
          :radius => working_width / 2,
          :origin => origin,
        )
      end

      # Draw polygon
      draw_polygon(
        :canvas => canvas,
        :working_width => working_width,
        :origin => origin,
        :point_count => point_count,
        :initial_offset => (360 / point_count) * i,
        :connect_to_center => ((i == recurse_depth-1 and rand(1..2) == 1) or
                               i == recurse_depth-2) ? true : false,
        :styles => {
          :fill_opacity => (i == recurse_depth-1) ? 1.0 : 1.0
        }
      )

      # Draw an array of border circles if we want to
      top_range = (recurse_depth-1) - i
      top_range = 1 if top_range < 1
      if not border_circles_drawn and i > 1 and rand(1..top_range) == 1
        draw_rune_circles(
          :canvas => canvas,
          :working_width => working_width,
          :origin => origin,
          :circle_count => point_count,
          :rune_circle_radius => border_circle_radius
        )
        border_circles_drawn = true
      end

      # Adjust working width
      working_width -= working_width * 0.1
    end

    ###
    # Do some final bits in the center
    ###

    # Draw outer circle
    working_width *= 0.35
    draw_circle(
     :canvas => canvas,
     :radius => working_width / 2,
     :origin => origin,
    )

    # Draw inner circle
    working_width *= 0.7
    draw_circle(
     :canvas => canvas,
     :radius => working_width / 2,
     :origin => origin,
    )

    return working_width
  end
end
