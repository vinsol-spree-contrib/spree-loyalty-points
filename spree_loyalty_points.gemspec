# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_loyalty_points'
  s.version     = '1.0.3'
  s.summary     = 'Add loyalty points to spree'
  s.description = 'To award loyalty points and add loyalty points payment method to spree'
  s.required_ruby_version = '>= 1.9.3'
  s.files = Dir['LICENSE', 'README.md', 'app/**/*', 'config/**/*', 'lib/**/*', 'db/**/*']

  s.author    = ['Jatin Baweja', 'Sushant Mittal']
  s.email     = 'info@vinsol.com'
  s.homepage  = 'http://vinsol.com'
  s.license   = "MIT"

  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 2.1'
end
