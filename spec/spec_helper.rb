# encoding: UTF-8

require 'bundler'
require 'pry'

Bundler.setup
Bundler.require

ENV['RACK_ENV'] = 'test'
set :environment, :test

require_relative "../no_light_sinatra.rb"

require 'minitest/pride'
require 'minitest/autorun'
require 'minitest/spec'
require 'rack/test'
require 'faker'

require 'database_cleaner'
DatabaseCleaner[:mongo_mapper].strategy = :truncation

require 'find'
%w{./config/initializers ./lib}.each do |load_path|
  Find.find(load_path) { |f| require f if f.match(/\.rb$/) }
end

class MiniTest::Spec
  include Rack::Test::Methods

  before(:each) do
    DatabaseCleaner[:mongo_mapper].start
  end

  after(:each) do
    visit '/logout'
    DatabaseCleaner[:mongo_mapper].clean
  end
end

OmniAuth.config.test_mode = true

def mock_with_valid_mlh_credentials!
  OmniAuth.config.mock_auth[:mlh] = OmniAuth::AuthHash.new({
    provider: :mlh,
    uid:      "1",
    info:     OmniAuth::AuthHash::InfoHash.new({
      email:        'grace.hopper@mlh.io',
      created_at:   Time.now,
      updated_at:   Time.now,
      first_name:   'Grace',
      last_name:    'Hopper',
      scopes:       ['default']
    })
  })
end
