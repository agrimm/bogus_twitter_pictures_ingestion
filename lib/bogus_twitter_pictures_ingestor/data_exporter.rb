require "csv"

# Export data via CSV. Code between my code and the library.
class DataExporter
  # http://stackoverflow.com/a/15912856/38765
  def run(heading_row, body_rows, filename)
    CSV.open(filename, "w",
             write_headers: true,
             headers: heading_row
    ) do |csv|
      body_rows.each do |body_row|
        csv << body_row
      end
    end
  end
end
