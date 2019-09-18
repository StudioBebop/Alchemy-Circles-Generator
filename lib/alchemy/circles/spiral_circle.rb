#################################################################
# Spiral Circle Generator Methods                               #
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
end
