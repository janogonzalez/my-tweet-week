require 'bundler'
Bundler.setup(:default)

require 'sinatra'
require 'haml'
require 'twitter'
require 'oauth'

class MyTweetWeek < Sinatra::Base
  set :haml, :format => :html5, :attr_wrapper => '"'
  enable :sessions, :static, :raise_errors
  set :public, File.join(File.dirname(__FILE__), 'public')

  get '/' do
    haml :index
  end
  
  get '/login' do
    request_token = consumer.get_request_token(:oauth_callback => ENV['OAUTH_CALLBACK'])

    session[:request_token] = request_token.token
    session[:request_token_secret] = request_token.secret
    
    redirect request_token.authorize_url
  end
  
  get '/oauth_callback' do
    request_token = OAuth::RequestToken.new(
      consumer,
      session[:request_token],
      session[:request_token_secret]
    )
    
    session[:request_token] = session[:request_token_secret] = nil
    
    access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])

    Twitter.configure do |config|
      config.consumer_key = ENV['CONSUMER_KEY']
      config.consumer_secret = ENV['CONSUMER_SECRET']
      config.oauth_token =  access_token.token
      config.oauth_token_secret = access_token.secret
    end

    redirect '/resume'
  end
  
  get '/resume' do
    today = Date.today
    monday = today - today.cwday + 1
    client = Twitter::Client.new
    search = Twitter::Search.new
    
    @screen_name = client.verify_credentials.screen_name
    @number_of_tweets = 0
    @number_of_mentions = 0
    
    results = search.from(@screen_name)
                    .since_date(monday)
                    .no_retweets
                    .per_page(100)
                    .fetch
                    
    @number_of_tweets += results.size
    
    while search.next_page?
      results = search.fetch_next_page
      @number_of_tweets += results.size
    end
    
    search.clear
    
    results = search.q("@#{@screen_name.gsub('@', '')}")
                    .since_date(monday)
                    .no_retweets
                    .per_page(100)
                    .fetch
                   
    @number_of_mentions += results.size
    
    while search.next_page?
      results = search.fetch_next_page
      @number_of_mentions += results.size
    end

    haml :resume
  end
  
  error Twitter::Unauthorized do
    redirect '/'
  end
  
  private
  
  def consumer
    @consumer ||= OAuth::Consumer.new(
      ENV['CONSUMER_KEY'],
      ENV['CONSUMER_SECRET'],
      :site => "https://api.twitter.com"
    )
  end
end
