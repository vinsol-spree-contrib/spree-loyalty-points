source 'https://rubygems.org'

group :assets do
  gem 'coffee-rails'
  gem 'sass-rails'
end


# Provides basic frontend and backend functionalities for testing purposes
gem 'spree_backend',  github: 'spree/spree', :branch => "3-0-stable"
gem 'spree_frontend', github: 'spree/spree', :branch => "3-0-stable"

# Provides basic authentication functionality for testing parts of your engine
gem 'spree_auth_devise', github: 'spree/spree_auth_devise', :branch => "3-0-stable"

group :test do
  gem 'shoulda-matchers', require: false
  gem 'capybara', '~> 2.1'
  gem 'database_cleaner'
  gem 'factory_girl', '~> 4.2'
  gem 'ffaker'
  gem 'rspec-rails',  '~> 2.13'
  gem 'simplecov'
  gem 'selenium-webdriver'
end

gemspec
