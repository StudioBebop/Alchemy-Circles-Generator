##encoding: utf-8
Encoding.default_external = Encoding.find 'UTF-8'
Encoding.default_internal = Encoding.find "UTF-8"

require 'bundler'
Bundler.require

require 'rvg/rvg'
include Magick
Magick.set_log_event_mask 'Exception'

module Alchemy
  # Set up some paths to things we might need
  @font_root = File.expand_path('../../data/fonts/', __FILE__)

  # Set up some default variables
  @default_dpi = 300
  @default_size = 6 # Default size (in inches) per side of the image
  @stroke_width_normal = 1
  @default_background_color = 'black'
  @default_stroke_color = 'white'

  def self.generate_transmutation_circle seed=nil, side_width=@default_size
    # Set up the DPI for rendering
    RVG::dpi = @default_dpi

    # Set up some variables we'll need all throughout the entire process
    point_count = 8 # [3, 4, 5, 6, 8, 9, 10]

    # Prep some grid variables
    grid_width = side_width * 100
    grid_origin = [grid_width / 2, grid_width / 2]

    # Init our RVG object and then drop into a block to work on it
    rvg = RVG.new(side_width.in, side_width.in).viewbox(0, 0, grid_width, grid_width) do | canvas |
      # Set the colors for our canvas
      background_color = @default_background_color
      stroke_color = @default_stroke_color
      stroke_width = @stroke_width_normal
      canvas.background_fill = background_color
      canvas.styles(
        :stroke => stroke_color,
        :fill => background_color,
        :fill_opacity => 1.0,
        :stroke_width => stroke_width,
      )

      # Instantiate our current "working_width"
      border_padding = 0.03 # Percentage of total canvas to shrink in on before drawing
      working_width = grid_width - (grid_width * border_padding)

      # Draw a border for our circle
      working_width = draw_border(
        :canvas => canvas,
        :working_width => working_width,
        :origin => grid_origin,
        :point_count => point_count,
        :stroke_width => stroke_width,
        :runes_around_border => true,
#        :zig_zag_around_border => true,
#        :blank_space_around_border => true
      )

      # Spiral Circle
#      if false
#      point_count = 4 # 2, 3, 4, 5 - 12
      working_shift = draw_spiral_circle(
        :canvas => canvas,
        :origin => grid_origin,
        :working_width => working_width - (working_width * 0.15),
        :point_count => point_count,
        :stroke_width => stroke_width,
        :stroke_color => stroke_color,
      )
#      end

      # Draw a summoning circle
#      if false
      working_shift = draw_summoning_circle(
        :canvas => canvas,
        :origin => grid_origin,
        :working_width => working_width,
        :point_count => point_count,
        :stroke_width => stroke_width,
        :stroke_color => stroke_color,
        :interconnect_circles => false
      )
      working_width = working_shift
#      end

      # Draw a recursive polygons circle
      if false
      point_count = 6 # 5, 6, 8, 9, 10, 12
      draw_summoning_circle(
        :canvas => canvas,
        :origin => grid_origin,
        :working_width => working_width,
        :point_count => point_count,
        :stroke_width => stroke_width,
        :stroke_color => stroke_color
      )
      end

    end

    # Return our RVG object for writing or further manipuatlion
    return rvg
  end
end

# Load other classes
require_relative 'alchemy/borders'
require_relative 'alchemy/shapes'
require_relative 'alchemy/runes'
require_relative 'alchemy/spirals'
Dir.glob("#{File.dirname(__FILE__)}/alchemy/circles/*").each do | wrapper |
  require wrapper
end
