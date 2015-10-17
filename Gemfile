ruby   '1.9.3'
source 'https://rubygems.org/'

# App Stack

gem 'sinatra', '~> 1.4'
gem 'sinatra-contrib'
gem 'mongo_mapper'
gem 'bson_ext'

gem 'zippy'

group :development do
  gem 'sinatra-reloader'
end

group :development, :test do
  gem 'rake', '~> 10.0'
end

group :test do
  gem 'minitest',               '~> 5.1'
  gem 'rack-test',              '~> 0.6.1'
  gem 'capybara',               '~> 1.1'
  gem 'capybara-webkit',        '~> 0.11'
  gem 'capybara_minitest_spec', '~> 0.2'
  gem 'faker'
  gem 'database_cleaner'
end
