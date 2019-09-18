#################################################################
# Recursive Polygons Circle Generator Methods                   #
#################################################################

module Alchemy
  ###
  # Draw a recursive polygons circle
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
  #  - recurse_depth
  #
  ###

  def self.draw_recursive_polygons_circle options={}
    # Break out the variables we'll need from our options
    canvas = options[:canvas]
    working_width = options[:working_width]
    origin = options[:origin]
    point_count = options[:point_count]
    stroke_width = options[:stroke_width]
    stroke_width = @default_stroke_width if not stroke_width
    stroke_color = options[:stroke_color]
    stroke_color = @default_stroke_color if not stroke_color
    recurse_depth = options[:recurse_depth]
    recurse_depth = 3 if not recurse_depth

    # Draw our border polygon that will connect all of our recursed polygons
    draw_polygon(
      :canvas => canvas,
      :working_width => working_width,
      :origin => origin,
      :point_count => point_count
    )

    # Draw our recursing/shrinking polygons
    0.upto(recurse_depth - 1).each do | depth_level |
      0.upto(point_count).each do | i |
        offset = (360 / point_count) * i
        offset += ((360 / point_count) * depth_level) / 2
        draw_polygon(
          :canvas => canvas,
          :working_width => working_width,
          :origin => origin,
          :point_count => point_count,
          :initial_offset => offset,
          :skip_point_count => 1
        )
      end

      # Get lines for two shapes
      lines = []
      0.upto(point_count).each do | i |
        offset = (360 / point_count) * i
        offset += ((360 / point_count) * depth_level) / 2

        points_x, points_y = points_around_origin(
          :origin => origin,
          :line_length => working_width / 2,
          :point_count => point_count,
          :initial_offset => offset,
          :skip_point_count => 1
        )
        lines << [
          points_x[0], points_y[0],
          points_x[1], points_y[1]
        ]
        break if lines.count == 2
      end

      ###
      # Find the intersection between two of the lines on our polygons
      # Shrink our working_widt using that info
      ###

      # Prep our x and y values
      x1 = lines[0][0]
      y1 = lines[0][1]
      x2 = lines[0][2]
      y2 = lines[0][3]
      x3 = lines[1][0]
      y3 = lines[1][1]
      x4 = lines[1][2]
      y4 = lines[1][3]

      # Calculate the coordinates for our intersection
      int_x = (((x1*y2)-(y1*x2))*(x3-x4)) - ((x1-x2)*((x3*y4)-(y3*x4)))
      int_x /= ((x1-x2)*(y3-y4)) - ((y1-y2)*(x3-x4))
      int_y = (((x1*y2)-(y1*x2))*(y3-y4)) - ((y1-y2) * ((x3*y4)-(y3*x4)))
      int_y /= ((x1-x2)*(y3-y4)) - ((y1-y2)*(x3-x4))

      # Calculate the lengths of all sides of the triangle
      side_len_1 = Math.sqrt(
        ((x3-x2)**2) + ((y3-y2)**2)
      )
      side_len_2 = Math.sqrt(
        ((x3-int_x)**2) + ((y3-int_y)**2)
      )
      side_len_3 = Math.sqrt(
        ((x2-int_x)**2) + ((y2-int_y)**2)
      )

      # Calculate height of triangle using Heron's Formula
      p = (side_len_1 + side_len_2 + side_len_3) / 2
      area = Math.sqrt(
        p * (p - side_len_1) * (p - side_len_2) * (p - side_len_3)
      )
      height = 2 * (area / side_len_1)

      # Adjust working width
      working_width -= height * 3
    end

    return working_width
  end
end
