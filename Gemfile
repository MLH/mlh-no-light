ruby   '1.9.3'
source 'https://rubygems.org/'

gem 'bson_ext'
gem 'mongo_mapper'
gem 'sinatra', '~> 1.4'
gem 'sinatra-contrib'
gem 'zippy'

group :development do
  gem 'sinatra-reloader'
end

group :development, :test do
  gem 'rake', '~> 10.0'
end

group :test do
  gem 'capybara',               '~> 1.1'
  gem 'capybara-webkit',        '~> 0.11'
  gem 'capybara_minitest_spec', '~> 0.2'
  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'faker'
  gem 'minitest',               '~> 5.1'
  gem 'rack-test',              '~> 0.6.1'
end