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
    recurse_depth = rand(3..6) if not recurse_depth

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
      while old_point_count ==  point_count or (point_count % 2 != old_point_count % 2)#or point_count % 2 != 0 do
        point_count = rand(4..10)
      end

      # Draw polygon
      draw_polygon(
        :canvas => canvas,
        :working_width => working_width,
        :origin => origin,
        :point_count => point_count,
        :initial_offset => (360 / point_count) * i,
        :connect_to_center => (i == 0 or i == recurse_depth-2) ? true : false,
        :styles => {
          :fill_opacity => (i == recurse_depth-1) ? 1.0 : 1.0
        }
      )

      # Adjust working width
      working_width -= working_width * 0.1
    end

    return working_width
  end
end
