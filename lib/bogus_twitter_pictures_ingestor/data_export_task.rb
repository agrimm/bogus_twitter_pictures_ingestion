# Export all data to CSV files.
class DataExportTask
  def initialize(texts, username_text_pairs, usernames, data_exporter)
    @texts = texts
    @username_text_pairs = username_text_pairs
    @usernames = usernames
    @data_exporter = data_exporter

    # texts and usernames belong to tweets and users respectively
    @tweet_id_hash = create_tweet_id_hash
    @user_id_hash = create_user_id_hash
    @user_id_tweet_id_pairs = determine_user_id_tweet_id_pairs

    @tweet_export_task = create_tweet_export_task
    @user_export_task = create_user_export_task
    @user_tweet_export_task = create_user_tweet_export_task
  end

  def create_tweet_id_hash
    @texts.each_with_index.each_with_object({}) do |(text, i), result|
      fail unless text.respond_to?(:to_str)
      id = i + 1
      result[text] = id
    end
  end

  def create_user_id_hash
    @usernames.each_with_index.each_with_object({}) do |(username, i), result|
      fail unless username.respond_to?(:to_str)
      id = i + 1
      result[username] = id
    end
  end

  def determine_user_id_tweet_id_pairs
    @username_text_pairs.map do |username, text|
      user_id = @user_id_hash.fetch(username)
      tweet_id = @tweet_id_hash.fetch(text)
      [user_id, tweet_id]
    end
  end

  def create_tweet_export_task
    TweetExportTask.new(@tweet_id_hash, @data_exporter)
  end

  def create_user_export_task
    UserExportTask.new(@user_id_hash, @data_exporter)
  end

  def create_user_tweet_export_task
    UserTweetExportTask.new(@user_id_tweet_id_pairs, @data_exporter)
  end

  def run
    @tweet_export_task.run
    @user_export_task.run
    @user_tweet_export_task.run
  end

  # Export tweets
  class TweetExportTask
    HEADING_ROW = %w(id text)
    EXPORT_FILENAME = "tweet.csv"

    def initialize(tweet_id_hash, data_exporter)
      @tweet_id_hash = tweet_id_hash
      @data_exporter = data_exporter

      @body_rows = determine_body_rows
    end

    def determine_body_rows
      @tweet_id_hash.to_a.map(&:reverse)
    end

    def run
      @data_exporter.run(HEADING_ROW, @body_rows, EXPORT_FILENAME)
    end
  end

  # Export users
  class UserExportTask
    HEADING_ROW = %w(id username)
    EXPORT_FILENAME = "user.csv"

    def initialize(user_id_hash, data_exporter)
      @user_id_hash = user_id_hash
      @data_exporter = data_exporter

      @body_rows = determine_body_rows
    end

    def determine_body_rows
      @user_id_hash.to_a.map(&:reverse)
    end

    def run
      @data_exporter.run(HEADING_ROW, @body_rows, EXPORT_FILENAME)
    end
  end

  # Export the relationship between users and tweets
  class UserTweetExportTask
    HEADING_ROW = %w(user_id tweet_id)
    EXPORT_FILENAME = "user_tweet.csv"

    def initialize(user_id_tweet_id_pairs, data_exporter)
      @user_id_tweet_id_pairs = user_id_tweet_id_pairs
      @data_exporter = data_exporter

      @body_rows = @user_id_tweet_id_pairs
    end

    def run
      @data_exporter.run(HEADING_ROW, @body_rows, EXPORT_FILENAME)
    end
  end
end
