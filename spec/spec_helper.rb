# encoding: UTF-8

require 'bundler'
require 'pry'

Bundler.setup
Bundler.require

ENV['RACK_ENV'] = 'test'
set :environment, :test

require_relative '../no_light_sinatra'

require 'capybara/rspec'
require 'rack/test'
require 'database_cleaner/core'
require 'database_cleaner/mongo/deletion'

client = Mongo::Client.new('mongodb://127.0.0.1/no_light_test')
cleaner = DatabaseCleaner::Cleaner.new(:mongo, db: client.database)
Capybara.app = NoLightSinatra


RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:suite) do
    cleaner.strategy = :deletion
    cleaner.clean_with(:deletion)
  end

  config.before(:each) do
    cleaner.start
  end

  config.after(:each) do
    cleaner.clean
  end
end

class Capybara::Session
  def params
    Hash[*URI.parse(current_url).query.split(/\?|=|&/)]
  end

  def find_classes(selector)
    find(selector)["class"].to_s.split(' ').map(&:to_sym)
  end
end

OmniAuth.config.test_mode = true

def mock_with_valid_mlh_credentials!
  OmniAuth.config.mock_auth[:mlh] = OmniAuth::AuthHash.new({
                                                             provider: :mlh,
                                                             uid: "1",
                                                             info: OmniAuth::AuthHash::InfoHash.new({
                                                                                                      email: 'grace.hopper@mlh.io',
                                                                                                      created_at: Time.now,
                                                                                                      updated_at: Time.now,
                                                                                                      first_name: 'Grace',
                                                                                                      last_name: 'Hopper',
                                                                                                      scopes: ['default']
                                                                                                    })
                                                           })
end

