# encoding: UTF-8

require 'bundler'
require 'coveralls'

Bundler.setup
Bundler.require

Coveralls.wear!

ENV['RACK_ENV'] = 'test'
set :environment, :test

require_relative "../no_light_sinatra.rb"

require 'minitest/pride'
require 'minitest/autorun'
require 'minitest/spec'
require 'rack/test'
require 'faker'

require 'database_cleaner'
DatabaseCleaner.strategy = :truncation

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
    DatabaseCleaner.clean
  end
end
