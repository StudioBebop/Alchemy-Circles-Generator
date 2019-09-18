#################################################################
# Summoning Circle Generator Methods                            #
#################################################################

module Alchemy
  ###
  # Draw a summoning circle
  #
  # Required Args:
  #  - canvas
  #  - origin
  #  - working_width
  #  - point_count
  #
  # Optional Args:
  #  - draw_border
  #  - stroke_width
  #  - stroke_color
  #  - rune_circle_size_ratio (percentage of working_width that our rune cicles will be)
  #  - interconnect_circles
  #
  ###

  def self.draw_summoning_circle options={}
    # Break out the variables we'll need from our options
    canvas = options[:canvas]
    working_width = options[:working_width]
    origin = options[:origin]
    point_count = options[:point_count]
    stroke_width = options[:stroke_width]
    stroke_width = @default_stroke_width if not stroke_width
    rune_circle_size_ratio = options[:rune_circle_size_ratio]
    rune_circle_size_ratio = 0.14 if not rune_circle_size_ratio
    stroke_color = options[:stroke_color]
    stroke_color = @default_stroke_color if not stroke_color
    interconnect_circles = options[:interconnect_circles]
    interconnect_circles = true if not options.has_key? :interconnect_circles
    draw_border = options[:draw_border]
    draw_border = true if not options.has_key? :draw_border

    # Draw aour border circle(s)
    working_width = draw_border(
      :canvas => canvas,
      :working_width => working_width,
      :origin => origin,
      :point_count => point_count,
      :stroke_width => stroke_width,
      :runes_around_border => true,
#      :zig_zag_around_border => true,
#      :blank_space_around_border => true
    ) if draw_border

    # Draw the polygon that will connect the cirlces together
    draw_polygon(
      :canvas => canvas,
      :working_width => working_width - (working_width * rune_circle_size_ratio),
      :origin => origin,
      :point_count => point_count,
    )

    # Draw our interconnected polygons
    if interconnect_circles
      0.upto(point_count).each do | i |
        draw_polygon(
          :canvas => canvas,
          :working_width => working_width - (working_width * rune_circle_size_ratio),
          :origin => origin,
          :point_count => point_count,
          :initial_offset => (360 / point_count) * i,
          :styles => {:fill_opacity => 0.0},
          :skip_point_count => 1
        )
      end
    end

    # Draw rune circles around the inner border
    rune_circle_radius = (working_width * rune_circle_size_ratio) / 2
    working_width -= (working_width * rune_circle_size_ratio)
    draw_rune_circles(
      :canvas => canvas,
      :working_width => working_width,
      :origin => origin,
      :circle_count => point_count,
      :rune_circle_radius => rune_circle_radius,
      :stroke_color => stroke_color
    )
    working_width -= rune_circle_radius * 2

    return working_width
  end

  ###
  # Draw fancy rune circles
  #
  # Required Args:
  #  - canvas
  #  - working_width
  #  - origin
  #  - circle_count (how many circles do we want?)
  #  - rune_circle_radius
  #
  ###
  def self.draw_rune_circles options={}
    # Break out the variables we'll need from our options
    canvas = options[:canvas]
    working_width = options[:working_width]
    origin = options[:origin]
    circle_count = options[:circle_count]
    rune_circle_radius = options[:rune_circle_radius]
    stroke_color = options[:stroke_color]

    # Get origin points for all circles
    points_x, points_y = points_around_origin(
      :origin => origin,
      :line_length => working_width / 2,
      :point_count => circle_count
    )

    # Draw those circles! (and runes)
    runes = @rune_chars.sample circle_count
#    runes = @rune_chars
    0.upto(circle_count - 1).each do | i |
      # Draw the circle
      draw_circle(
        :canvas => canvas,
        :radius => rune_circle_radius,
        :origin => [points_x[i], points_y[i]],
        :styles => options[:styles],
        :draw_center_rune => true,
        :rune_char => runes[i][0],
        :font_path => runes[i][1],
        :initial_offset => (360 / circle_count) * i
      )
    end
  end
end
