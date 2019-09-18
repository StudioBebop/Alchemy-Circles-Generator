#################################################################
# Basic shape drawing methods and helper methods                #
#################################################################

module Alchemy
  ###
  # Get all points in a circle around a given origin
  #
  # Required Args:
  #  - origin
  #  - line_length
  #  - point_count (how many points do we want?)
  #
  # Optional Args:
  #  - initial_offset (angle offset to add to all of our angle calculations)
  #  - skip_point_count (number of points to skip as we find our points)
  #
  ###
  def self.points_around_origin options={}
    # Break out the variables we'll need from our options
    origin = options[:origin]
    line_length = options[:line_length]
    point_count = options[:point_count]
    initial_offset = options[:initial_offset]
    initial_offset = 0 if not initial_offset
    skip_point_count = options[:skip_point_count]
    skip_point_count = -1 if not skip_point_count
    skip_point_count = -1 if skip_point_count < 1

    # Iterate through all angles to get the end points
    point_counter = 0
    points_x = []
    points_y = []
    0.upto(point_count - 1).each do | i |
      if point_counter == skip_point_count
        point_counter = 0
        next
      end
      point_counter += 1

      # Set the rotation and angle offset
      angle_offset = initial_offset
      angle = 360 / point_count
      rotation_angle = angle_offset + (angle * i)

      # Calcualte the end point given our distance from the center point
      x2 = origin[0] + (line_length * Math.cos(rotation_angle * (Math::PI / 180)))
      y2 = origin[1] + (line_length * Math.sin(rotation_angle * (Math::PI / 180)))
      points_x << x2
      points_y << y2
    end

    return points_x, points_y
  end

  ###
  # Draw a circle
  #
  # Required Args:
  #  - canvas
  #  - origin
  #  - radius
  #
  # Optional Args:
  #  - stroke_color
  #  - draw_center_point (true | false) :default => false
  #  - draw_center_rune (true | false) :default => false
  #  - initial_offset (angle offset to add to all of our angle calculations)
  #  - rune_char
  #  - font_path
  #
  ###
  def self.draw_circle options={}
    # Break out the variables we'll need from our options
    canvas = options[:canvas]
    radius = options[:radius]
    origin = options[:origin]
    stroke_color = @default_stroke_color if not options[:stroke_color]
    draw_center_point = options[:draw_center_point]
    draw_center_point = false if not draw_center_point
    draw_center_rune = options[:draw_center_rune]
    draw_center_rune = false if not draw_center_rune
    initial_offset = options[:initial_offset]
    initial_offset = 0 if not initial_offset
    if options[:initial_offset]
      initial_offset += 90
    end

    # Draw our shape
    canvas.g do | shapes |
      # Set styles
      shapes.styles(options[:styles]) if options[:styles]
      shapes.styles(:fill_opacity => 1.0)

      # Draw circle
      shapes.circle(
        radius,
        origin[0],
        origin[1]
      )

      # Draw a center point if we need to
      if draw_center_point
        center_point_radius = radius * 0.15
        shapes.circle(
          center_point_radius,
          origin[0],
          origin[1]
        ).styles(
          :fill => stroke_color,
          :fill_opacity => 1.0
        )
      end

      # Draw a rune if we need to
      if draw_center_rune
        draw_rune(
          :canvas => shapes,
          :working_width => radius * 2,
          :origin => origin,
          :rune_char => options[:rune_char],
          :font_path => options[:font_path],
          :initial_offset => initial_offset
        )
      end
    end
  end

  ###
  # Draw a polygon
  #
  # Required Args:
  #  - canvas
  #  - origin
  #  - working_width (how wide the polygon should be from point to point)
  #  - point_count (how many points do we want?)
  #
  # Optional Args:
  #  - initial_offset (angle offset to add to all of our angle calculations)
  #  - skip_point_count (number of points to skip as we find our points)
  #  - connect_to_center (draw liens connecting all points to the origin)
  #
  ###
  def self.draw_polygon options={}
    # Break out the variables we'll need from our options
    canvas = options[:canvas]
    working_width = options[:working_width]
    origin = options[:origin]
    point_count = options[:point_count]
    initial_offset = options[:initial_offset]
    initial_offset = 0 if not initial_offset
    skip_point_count = options[:skip_point_count]
    skip_point_count = -1 if not skip_point_count
    skip_point_count = -1 if skip_point_count < 1
    connect_to_center = options[:connect_to_center]
    connect_to_center = false if not connect_to_center

    # Get points for our polygon
    points_x, points_y = points_around_origin(
      :origin => origin,
      :line_length => working_width / 2,
      :point_count => point_count,
      :initial_offset => initial_offset,
      :skip_point_count => skip_point_count
    )

    # Draw the polygon
    canvas.g do | shapes |
      shapes.styles(options[:styles]) if options[:styles]
      shapes.polygon(
        points_x, points_y
      )

      if connect_to_center
        0.upto(points_x.count - 1).each do | i |
          shapes.line(
            origin[0], origin[1],
            points_x[i], points_y[i]
          )
        end
      end
    end
  end
end
