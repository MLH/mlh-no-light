# Load path and gems/bundler
$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

require "bundler"
Bundler.require

require 'sentry-ruby'

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.traces_sample_rate = 0.1
  config.profiles_sample_rate = 0.1
end

use Sentry::Rack::CaptureExceptions unless ENV["RACK_ENV"] == "test"
require "find"
%w{config/initializers lib models}.each do |load_path|
  Find.find(load_path) { |f|
    require f unless f.match(/\/\..+$/) || File.directory?(f)
  }
end

require "sinatra/reloader" if development?
require "securerandom"
require "tempfile"

# Load app
require "./no_light_sinatra"
run NoLightSinatra
