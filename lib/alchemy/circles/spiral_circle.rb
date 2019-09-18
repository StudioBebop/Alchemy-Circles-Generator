#################################################################
# spiral Circle Generator Methods                   #
#################################################################

module Alchemy
  ###
  # Draw a curvy line circle
  #
  # Required Args:
  #  - canvas
  #  - origin
  #  - working_width
  #  - point_count
  #
  # Optional Args:
  #  - stroke_width
  #  - stroke_color
  #  - draw_border
  #
  ###

  def self.draw_spiral_circle options={}
    # Break out the variables we'll need from our options
    canvas = options[:canvas]
    working_width = options[:working_width]
    origin = options[:origin]
    point_count = options[:point_count]
    stroke_width = options[:stroke_width]
    stroke_width = @default_stroke_width if not stroke_width
    stroke_color = options[:stroke_color]
    stroke_color = @default_stroke_color if not stroke_color
    draw_border = options[:draw_border]
    draw_border = true if not options.has_key? :draw_border

    # Draw our outer circle
    if draw_border
      draw_circle(
        :canvas => canvas,
        :radius => working_width / 2,
        :origin => origin
      )
      working_width -= stroke_width * 2
    end

    # Draw our spiral radiating out from the center
    draw_spiral(
      :canvas => canvas,
      :radius => working_width / 2,
      :origin => origin,
      :point_count => point_count
    )

    # Draw a circle in the center of our spiral
    central_circle_radius = working_width / 2
    central_circle_radius *= 0.2
    draw_circle(
      :canvas => canvas,
      :radius => central_circle_radius,
      :origin => origin,
      :draw_center_point => false,
      :draw_center_rune => true,
      :styles => {
        :fill_opacity => 1.0
      }
    )

    return working_width
  end

  ###
  # Draw spiral going to/from a central origin point
  #
  # Required Args:
  #  - canvas
  #  - origin
  #  - radius
  #  - point_count
  #
  # Optional Args:
  #  - initial_offset (angle offset to add to all of our angle calculations)
  #  - skip_point_count (number of points to skip as we find our points)
  #  - styles
  #
  ###

  def self.draw_spiral options={}
    # Break out the variables we'll need from our options
    canvas = options[:canvas]
    radius = options[:radius]
    origin = options[:origin]
    point_count = options[:point_count]
    initial_offset = options[:initial_offset]
    initial_offset = 0 if not initial_offset
    skip_point_count = options[:skip_point_count]
    skip_point_count = -1 if not skip_point_count
    skip_point_count = -1 if skip_point_count < 1
    connect_to_center = options[:connect_to_center]
    connect_to_center = false if not connect_to_center

    # Get offsets of points around our origin to draw spiral to
    offsets = []
    point_counter = 0
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

      # Add angle to offsets
      offsets << rotation_angle
    end

    # Draw all of our lines
    0.upto(offsets.count - 1).each do | i |
      # Construct SVG path for our curvy line
      svg_path = get_spiral_path origin, radius + 1

      # Draw the curvy line
      canvas.g do | shapes |
        shapes.styles(options[:styles]) if options[:styles]

        shapes.path(
          svg_path
        ).rotate(offsets[i], origin[0], origin[1])
      end
    end
  end

  ###
  # Return a svg path spiral
  ###
  def self.get_spiral_path origin, total_radius
    # Rename spiral parameters for the formula r = a + bθ
    spacePerLoop = total_radius
    a = 0  # start distance from center
    b = spacePerLoop / Math::PI # space between each loop

    # convert angles to radians
    thetaStep = 30
    startTheta = 0
    endTheta = 360
    oldTheta = newTheta = startTheta * Math::PI / 180
    endTheta = endTheta * Math::PI / 180
    thetaStep = thetaStep * Math::PI / 180

    # radii
    oldR = a + b * newTheta
    newR = a + b * newTheta

    # start and end points
    oldPoint = {
      :x => 0,
      :y => 0
    }
    newPoint = {
      :x => origin[0] + newR * Math.cos(newTheta),
      :y => origin[1] + newR * Math.sin(newTheta)
    }

    # slopes of tangents
    oldslope  = (b * Math.sin(oldTheta) + (a + b * newTheta) * Math.cos(oldTheta))
    oldslope /= (b * Math.cos(oldTheta) - (a + b * newTheta) * Math.sin(oldTheta))
    newSlope = oldslope
    path = "M #{newPoint[:x]},#{newPoint[:y]} "

    while newR < total_radius do
      oldTheta = newTheta
      newTheta += thetaStep

      oldR = newR
      newR = a + b * newTheta
      break if newR > total_radius

      oldPoint[:x] = newPoint[:x]
      oldPoint[:y] = newPoint[:y]
      newPoint[:x] = origin[0] + newR * Math.cos(newTheta)
      newPoint[:y] = origin[1] + newR * Math.sin(newTheta)

      # Slope calculation with the formula:
      # (b * sinΘ + (a + bΘ) * cosΘ) / (b * cosΘ - (a + bΘ) * sinΘ)
      aPlusBTheta = a + b * newTheta

      oldSlope = newSlope
      newSlope = (b * Math.sin(newTheta) + aPlusBTheta * Math.cos(newTheta))
      newSlope /= (b * Math.cos(newTheta) - aPlusBTheta * Math.sin(newTheta))

      oldIntercept = -(oldSlope * oldR * Math.cos(oldTheta) - oldR * Math.sin(oldTheta))
      newIntercept = -(newSlope * newR* Math.cos(newTheta) - newR * Math.sin(newTheta))

      controlPoint = lineIntersection(oldSlope, oldIntercept, newSlope, newIntercept)

      # Offset the control point by the center offset.
      controlPoint[:x] += origin[0]
      controlPoint[:y] += origin[1]

      path += "Q #{controlPoint[:x]},#{controlPoint[:y]} #{newPoint[:x]},#{newPoint[:y]} "
    end

    return path
  end

  def self.lineIntersection m1, b1, m2, b2
    x = (b2 - b1) / (m1 - m2)
    return {
      :x => x,
      :y => m1 * x + b1
    }
  end

end
