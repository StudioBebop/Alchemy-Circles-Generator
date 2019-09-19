require File.expand_path('../../lib/alchemy', __FILE__)

module Alchemy
  class WebApp < Sinatra::Base
    set :public_folder, 'public'
    set :protection, :except => :path_traversal

    # Load route files
    Dir[File.dirname(__FILE__) + '/routes/*'].each do | route_file |
      load route_file
    end

    # Load helper files
    Dir[File.dirname(__FILE__) + '/helpers/*'].each do | helper_file |
      load helper_file
    end

  end
end
