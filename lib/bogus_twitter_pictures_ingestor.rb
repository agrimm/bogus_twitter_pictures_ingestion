$LOAD_PATH.unshift File.join(__dir__, "bogus_twitter_pictures_ingestor")

require "twitter_client"
require "twitter_ingestion_task"
require "data_exporter"
require "data_export_task"
require "forwardable"

# Ingest data about bogus twitter pictures
class BogusTwitterPicturesIngestor
  extend Forwardable

  def_delegators :@data_export_task, :run

  def self.run
    twitter_client = create_twitter_client
    twitter_ingestion_task = create_twitter_ingestion_task(twitter_client)
    bogus_twitter_pictures_ingestor = new(twitter_ingestion_task)
    bogus_twitter_pictures_ingestor.run
  end

  def self.create_twitter_client
    TwitterClient.new_using_configuration
  end

  def self.create_twitter_ingestion_task(twitter_client)
    TwitterIngestionTask.new_using_configuration(twitter_client)
  end

  def initialize(twitter_ingestion_task)
    @twitter_ingestion_task = twitter_ingestion_task

    @texts = determine_texts
    @username_text_pairs = determine_username_text_pairs
    @usernames = determine_usernames

    @data_export_task = create_data_export_task
  end

  def determine_texts
    @twitter_ingestion_task.texts
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

  def create_data_export_task
    data_exporter = DataExporter.new
    DataExportTask.new(@texts, @username_text_pairs, @usernames, data_exporter)
  end
end
