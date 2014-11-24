require 'twitter'
require './okikisen'
require './page_log'

client = Twitter::REST::Client.new(
  consumer_key: ENV['CONSUMER_KEY'],
  consumer_secret: ENV['CONSUMER_SECRET'],
  access_token: ENV['ACCESS_TOKEN'],
  access_token_secret: ENV['ACCESS_TOKEN_SECRET']
)

def update
  prev = PageLog.last
  text = Okikisen.scrape
  PageLog.create text: text
  PageLog.cleanup

  Okikisen.new(text).messages(prev: Okikisen.new(prev.text)).each do |message|
    client.update message
  end
end

loop do
  update
  sleep 15*60
end
