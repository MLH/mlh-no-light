ruby '3.4.13'
source 'https://rubygems.org'

gem 'mongo_mapper', '0.16.0'
gem 'sinatra'
gem 'sinatra-contrib'
gem 'rubyzip', '~> 2.3.2', require: 'zip'
gem 'omniauth'
gem 'omniauth-mlh', '~> 4.2'
gem 'ostruct'
gem 'puma'
gem "stackprof"
gem "sentry-ruby"


group :development do
  gem 'sinatra-reloader'
end

group :development, :test do
  gem 'pry'
  gem 'rake'
  gem 'dotenv'
end

group :test do
  gem 'rspec'
  gem 'capybara'
  gem 'webdrivers'
  gem 'database_cleaner-mongo'
  gem 'faker'
  gem 'rack-test'
end
