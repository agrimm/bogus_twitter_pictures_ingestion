# Get data from twitter
class TwitterIngestionTask
  attr_reader :texts

  CONFIGURATION_FILENAME = "config/bogus_twitter_pictures_ingestor.yml"

  def self.new_using_configuration(twitter_client)
    configuration_text = File.read(CONFIGURATION_FILENAME)
    configuration = YAML.load(configuration_text)
    username = configuration.fetch(:username)
    count = configuration.fetch(:count)
    include_rts = configuration.fetch(:include_rts)
    new(twitter_client, username, count, include_rts)
  end

  def initialize(twitter_client, username, count, include_rts)
    @twitter_client = twitter_client
    @username = username
    @count = count
    @include_rts = include_rts

    @tweets = determine_tweets
    @texts = determine_texts
  end

  def determine_tweets
    @twitter_client.get_tweets(@username, @count, @include_rts)
  end

  def determine_texts
    @tweets.map(&:text)
  end
end
