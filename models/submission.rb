# models/submission.rb

class Submission
  include MongoMapper::Document

  scope :duplicates,    lambda { |name, hackathon, html| where(name: name, hackathon: hackathon, html: html) }
  scope :by_hackathon,  lambda { |hackathon| where(hackathon: hackathon) }

  # Statistical functions
  # How many lines of code have they written, how many bytes is it?
  def bytes; string_io_instance.each_byte.to_a.count; end
  def lines; string_io_instance.each_line.to_a.count; end

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
    formatted_time = [created_at.hour, created_at.min, created_at.sec].join('_')

    "#{hackathon}/#{formatted_name}_#{formatted_time}_#{objectid_counter}.html"
  end

  key :name,      String
  key :hackathon, String
  key :html,      String
  key :seconds,   Integer
  
  timestamps!

  private

  def string_io_instance
    StringIO.new(html)
  end

  def objectid_counter
    self.id.to_s[-6..-1]
  end
end