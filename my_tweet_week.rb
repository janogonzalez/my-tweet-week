require 'bundler'
Bundler.setup(:default)

require 'sinatra'
require 'haml'
require 'twitter'
require 'oauth'

class MyTweetWeek < Sinatra::Base
  set :haml, :format => :html5, :attr_wrapper => '"'
  enable :sessions
  
  before do
    @consumer ||= OAuth::Consumer.new(
      ENV['CONSUMER_KEY'],
      ENV['CONSUMER_SECRET'],
      :site => "https://api.twitter.com"
    )

    if !session[:access_token].nil? && !session[:access_token_secret].nil?
      @access_token = OAuth::AccessToken.new(
        @consumer,
        session[:access_token],
        session[:access_token_secret]
      )
    end
  end
  
  get '/' do
    haml :index
  end
  
  get '/login' do
    @request_token = @consumer.get_request_token(:oauth_callback => ENV['OAUTH_CALLBACK'])
    
    session[:request_token] = @request_token.token
    session[:request_token_secret] = @request_token.secret
    
    redirect @request_token.authorize_url
  end
  
  get '/oauth_callback' do
    @request_token = OAuth::RequestToken.new(
      @consumer,
      session[:request_token],
      session[:request_token_secret]
    )
    
    session[:request_token] = session[:request_token_secret] = nil 
    
    @access_token = @request_token.get_access_token
    
    session[:access_token] = @access_token.token
    session[:access_token_tsecret] = @access_token.secret
    
    redirect '/resume'
  end
  
  get '/resume' do
    haml :resume
  end
end
