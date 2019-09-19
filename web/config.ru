ENV['INLINEDIR'] = '/home/brandon/.ruby_inline'

require 'sinatra/base'
require './app'

run Alchemy::WebApp
