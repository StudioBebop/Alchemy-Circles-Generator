##encoding: utf-8
Encoding.default_external = Encoding.find 'UTF-8'
Encoding.default_internal = Encoding.find "UTF-8"

require 'bundler'
Bundler.require

require 'rvg/rvg'
include Magick
Magick.set_log_event_mask 'Exception'

class String
  def to_seed
    chars = self.downcase.split("")
    chars.map! { |x| "#{x.ord}" }
    return (chars.join "").to_i
  end

  def to_random_seed_phrase
    str = self.gsub("_", " ")
    str = str.split(" ").map { |x| x.capitalize }
    str = str.join ""
    return str
  end
end

module Alchemy
  # Set up some paths to things we might need
  @font_root = File.expand_path('../../data/fonts/', __FILE__)

  # Set up some default variables
  @default_dpi = 200
  @default_side_width = 6 # Default size (in inches) per side of the image
  @default_stroke_width = 1
  @default_background_color = 'black'
  @default_stroke_color = 'white'
  @default_point_count_options = [3, 4, 5, 6, 8, 9, 10]

  # Circle types
  @circle_types = Dir.glob("#{File.dirname(__FILE__)}/alchemy/circles/*").map do | wrapper |
    wrapper.split("/")[-1].split(".rb")[0].to_sym
  end


  ###
  # Generate an alchemy circle RVG object
  #
  # Required Args:
  #  - circle_type
  #
  # Optional Args:
  #  - seed
  #  - dpi
  #  - side_width (width in inches for our canvas)
  #  - point_count
  #  - background_color
  #  - stroke_color
  #  - stroke_width
  #  - recurse_depth (depth to recurse for circle types that use that)
  #
  ###
  def self.generate_alchemy_circle options={}
    # Get our circle type
    raise "Missing circle type" if not options[:circle_type]
    raise "Invalid circle type" if not @circle_types.include? options[:circle_type]
    circle_type = options[:circle_type]

    # Set our seed if we have one
    srand(options[:seed]) if options[:seed]

    # Set up the DPI for rendering
    RVG::dpi = options[:dpi] || @default_dpi

    # Prep some grid variables
    side_width = options[:side_width] || @default_side_width
    grid_width = side_width * 100
    grid_origin = [
      grid_width / 2,
      grid_width / 2
    ]

    # Init our RVG object and then drop into a block to work on it
    rvg = RVG.new(side_width.in, side_width.in).viewbox(0, 0, grid_width, grid_width) do | canvas |
      # Set the colors for our canvas
      background_color = options[:background_color] || @default_background_color
      stroke_color = options[:stroke_color] || @default_stroke_color
      stroke_width = options[:stroke_width] || @default_stroke_width
      canvas.background_fill = background_color
      canvas.styles(
        :stroke => stroke_color,
        :fill => background_color,
        :fill_opacity => 1.0,
        :stroke_width => stroke_width,
      )

      # Set up our point count
      point_count = options[:point_count] || @default_point_count_options.sample(1)[0]

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
      if circle_type == :spiral_circle
        working_shift = draw_spiral_circle(
          :canvas => canvas,
          :origin => grid_origin,
          :working_width => working_width - (working_width * 0.15),
          :point_count => point_count,
          :stroke_width => stroke_width,
          :stroke_color => stroke_color,
        )
        working_width = working_shift
      end

      # Draw a summoning circle
      if circle_type == :summoning_circle
        working_shift = draw_summoning_circle(
          :canvas => canvas,
          :origin => grid_origin,
          :working_width => working_width,
          :point_count => point_count,
          :stroke_width => stroke_width,
          :stroke_color => stroke_color,
        )
        working_width = working_shift

      # Draw a recursive polygons circle
      elsif circle_type == :recursive_polygons_circle
        working_width = draw_recursive_polygons_circle(
          :canvas => canvas,
          :origin => grid_origin,
          :working_width => working_width,
          :point_count => point_count,
          :stroke_width => stroke_width,
          :stroke_color => stroke_color,
          :recurse_depth => options[:recurse_depth] || 3
        )
        working_width = working_shift

      # Draw a random shapes circle
      elsif circle_type == :random_polygons_circle
        working_width = draw_random_polygons_circle(
          :canvas => canvas,
          :origin => grid_origin,
          :working_width => working_width,
          :stroke_width => stroke_width,
          :stroke_color => stroke_color,
          :recurse_depth => options[:recurse_depth] || nil
        )
        working_width = working_shift
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
