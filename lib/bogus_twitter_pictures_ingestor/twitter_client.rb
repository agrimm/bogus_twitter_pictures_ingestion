require "yaml"
require "twitter"

# Twitter client. Code between my code and the library.
class TwitterClient
  CONFIGURATION_FILENAME = "config/twitter_client.yml"

  def self.new_using_configuration
    configuration_text = File.read(CONFIGURATION_FILENAME)
    configuration = YAML.load(configuration_text)
    consumer_key = configuration.fetch(:consumer_key)
    consumer_secret = configuration.fetch(:consumer_secret)
    client = Twitter::REST::Client.new do |c|
      c.consumer_key    = consumer_key
      c.consumer_secret = consumer_secret
    end
    new(client)
  end

  def initialize(client)
    @client = client
  end

  def get_tweets(username, count, include_rts)
    options = { count: count, include_rts: include_rts }
    @client.user_timeline(username, options)
  end
end
