# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_loyalty_points'
  s.version     = '1.2.0'
  s.summary     = 'Add loyalty points to spree'
  s.description = 'To award loyalty points and add loyalty points payment method to spree'
  s.required_ruby_version = '>= 2.0.0'
  s.files = Dir['LICENSE', 'README.md', 'app/**/*', 'config/**/*', 'lib/**/*', 'db/**/*']

  s.author    = ['Jatin Baweja', 'Sushant Mittal']
  s.email     = 'info@vinsol.com'
  s.homepage  = 'http://vinsol.com'
  s.license   = "MIT"

  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 3.2.0.rc2'
  s.add_development_dependency 'capybara', '~> 2.5'
  s.add_development_dependency 'coffee-rails', '~> 4.2.1'
  s.add_development_dependency 'database_cleaner', '~> 1.5.3'
  s.add_development_dependency 'factory_girl', '~> 4.5'
  s.add_development_dependency 'ffaker', '~> 2.2.0'
  s.add_development_dependency 'rspec-rails', '~> 3.4'
  s.add_development_dependency 'rspec-activemodel-mocks'
  s.add_development_dependency 'shoulda-matchers', '~> 3.1.1'
  s.add_development_dependency 'sass-rails', '~> 5.0.0'
  s.add_development_dependency 'selenium-webdriver', '~> 3.0.8'
  s.add_development_dependency 'simplecov', '~> 0.13.0'
  s.add_development_dependency 'sqlite3', '~> 1.3.13'
end
