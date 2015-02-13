$LOAD_PATH.unshift File.join(__dir__, "..", "lib", "bogus_twitter_pictures_ingestor")
$LOAD_PATH.unshift File.join(__dir__, "helpers")

require "minitest/autorun"
require "data_export_task"
require "fake_data_exporter"

# Test DataExportTask
class TestDataExportTask < Minitest::Test
  def create_fake_data_exporter
    FakeDataExporter.new
  end

  def test_data_export_task
    texts = [".@a It's fake"]
    username_text_pairs = [["a", ".@a It's fake"]]
    usernames = ["a"]
    fake_data_exporter = create_fake_data_exporter
    data_export_task = DataExportTask.new(texts, username_text_pairs, usernames, fake_data_exporter)
    data_export_task.run
  end
end
