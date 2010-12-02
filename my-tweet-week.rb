require 'bundler'
Bundler.setup(:default)

require 'sinatra'
require 'haml'

class MyTweetWeek < Sinatra::Base
  set :haml, :format => :html5, :attr_wrapper => '"'
  
  get '/' do
    haml :index
  end
  
  get '/resume' do
    haml :resume
  end
end
