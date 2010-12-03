require 'bundler'
Bundler.setup(:default, :test)

require 'rspec'
require 'rack/test'
require File.join(File.dirname(__FILE__), '..', 'my_tweet_week.rb')

set :environment, :test

describe "MyTweetWeek" do
  include Rack::Test::Methods

  def app
    @app ||= MyTweetWeek
  end
  
  describe "Routes tests" do
    it "should respond to /" do
      get '/'
      last_response.should be_ok
    end

    it "should respond to /resume and fail" do
      get '/resume'
      last_response.should_not be_ok
    end
  end
end

