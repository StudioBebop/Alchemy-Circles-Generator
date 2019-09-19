module Alchemy
  class WebApp < Sinatra::Base

    ############
    # Website Routes
    ############

    get ['/', '/random_circle'] do
      seed_text = "testbois town . biz"
      redirect "/generate_circle?s=#{RandomWord.phrases.next.to_random_seed_phrase}"
    end

    get '/generate_circle' do
      @seed_text = params['s']
      @seed = @seed_text.to_seed
      haml :index
    end

    get '/circle_image' do
      # Get params
      seed_text = params['s']
      seed = seed_text.to_seed

      # Prep options
      dpi = 300
      dpi = 600 if params['size'] == 'large'
      dpi = 100 if params['size'] == 'tiny'
      side_width = 3
      side_width = 6 if params['size'] == 'large'
      side_width = 2 if params['size'] == 'tiny'
      options = {
        :seed => seed,
        :dpi => dpi,
        :side_width => side_width,
        :circle_type => :random_polygons_circle
      }

      # Generate circle
      circ = Alchemy.generate_alchemy_circle options
      circ = circ.draw
      circ.format = 'png'

      # Return circle
      content_type 'image/png'
      if params['size'] == 'large'
        file_name = "#{@seed_text}.png"
        headers "Content-Disposition" => "attachment;filename=#{CGI.escape file_name}.pdf",
                "Content-Type" => "image/png"
        return circ.to_blob
      end
      return circ.to_blob
    end

    get '/lots_of_circles' do
      @seeds = []
      total_circles = 30
      0.upto(total_circles - 1).each { |x| @seeds << RandomWord.phrases.next.to_random_seed_phrase }
      ap @seeds

      haml :lots_of_circles
    end

  end
end
