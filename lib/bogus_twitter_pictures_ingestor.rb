$LOAD_PATH.unshift File.join(__dir__, "bogus_twitter_pictures_ingestor")

require "twitter_client"

# Ingest data about bogus twitter pictures
class BogusTwitterPicturesIngestor
  CONFIGURATION_FILENAME = "config/bogus_twitter_pictures_ingestor.yml"

  def self.run
    twitter_client = create_twitter_client
    new_using_configuration(twitter_client)
  end

  def self.create_twitter_client
    TwitterClient.new_using_configuration
  end

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
    @username_text_pairs = determine_username_text_pairs
    @usernames = determine_usernames
  end

  def determine_tweets
    @twitter_client.get_tweets(@username, @count, @include_rts)
  end

  def determine_texts
    @tweets.map(&:text)
  end

  def determine_username_text_pairs
    @texts.flat_map(&method(:determine_username_text_pairs_for_text))
  end

  def determine_username_text_pairs_for_text(text)
    # http://stackoverflow.com/questions/740590/regexp-how-to-extract-usernames-out-of-tweets-twitter-com/11643085#11643085
    results = text.scan(/(?<!\w)@(\w+)/)
    results.map do |result|
      username = result.first
      [username, text]
    end
  end

  def determine_usernames
    non_unique = @username_text_pairs.map(&:first)
    non_unique.uniq
  end
end
