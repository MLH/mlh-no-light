# models/submission.rb

class Submission
  include MongoMapper::Document

  scope :duplicates,    lambda { |name, hackathon, html| where(name: name, hackathon: hackathon, html: html) }
  scope :by_hackathon,  lambda { |hackathon| where(hackathon: hackathon.downcase) }

  # Statistical functions
  # How many lines of code have they written, how many bytes is it?
  def bytes; string_io_instance.bytes.count; end
  def lines; string_io_instance.lines.count; end

  # Checking for duplication
  # What if someone refreshes? Have they already submitted the exact same submission?
  def already_exists?
    Submission.duplicates(name, hackathon, html).any?
  end

  # Formatting the time it took to submit into "0:45" seconds format.
  def to_min_secs
    min  = ( seconds / 60 ).to_i rescue 0
    secs = ( seconds % 60 ).to_i rescue 0
    secs = "0#{secs}" if secs < 10

    [min, secs].select(&:present?).join(':')
  end

  # The filename we'll call it in the ZIP file.
  def filename
    formatted_name = "#{name}".tr(' ', '_')
    random_string  = SecureRandom.urlsafe_base64[0..4]

    "#{hackathon}/#{formatted_name}_#{random_string}.html"
  end

  key :name, String
  key :hackathon, String
  key :html, String
  key :seconds, Integer
  timestamps!

  private

  def string_io_instance
    @string_io_instance ||= StringIO.new(html)
  end
end