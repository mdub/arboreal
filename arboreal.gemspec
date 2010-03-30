require 'lib/arboreal/version'

Gem::Specification.new do |s|
  s.name             = "arboreal"
  s.version          = Arboreal::VERSION.dup
  s.platform         = Gem::Platform::RUBY
  s.required_ruby_version = ">= 1.8.7"
  s.summary          = "Efficient tree structures for ActiveRecord"
  s.description      = s.summary
  s.author           = "Mike Williams"
  s.email            = "mdub"
  s.homepage         = "http://github.com/mdub/arboreal"
  s.require_path     = "lib"
  s.files            = Dir["lib/**/*", "spec/**/*", "Rakefile"]
  s.add_development_dependency("rspec", ">= 1.2.9")
end
