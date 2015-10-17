# encoding: UTF-8

require 'bundler'

Bundler.setup
Bundler.require

ENV['RACK_ENV'] = 'test'

require_relative "../no_light_sinatra.rb"

require 'minitest/pride'
require 'minitest/autorun'
require 'minitest/spec'
require 'rack/test'
require 'faker'
require 'database_cleaner'

require 'find'

%w{./config/initializers ./lib}.each do |load_path|
  Find.find(load_path) { |f| require f if f.match(/\.rb$/) }
end

class MiniTest::Spec
  include Rack::Test::Methods

  before(:each) do
    DatabaseCleaner.start
  end

  after(:each) do
    DatabaseCleaner.clean_with(:truncation)
  end
end