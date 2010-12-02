require "bundler"
Bundler.setup

require "sinatra"

class MyTweetWeek
  get "/" do
    "My Tweet Week"
  end
end
