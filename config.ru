# Load path and gems/bundler
$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

require "bundler"
Bundler.require

# Local config
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
