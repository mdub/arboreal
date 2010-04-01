require 'lib/arboreal/version'

description = File.read("README.rdoc").split(/^=.*\n+/)[1]

Gem::Specification.new do |s|
  s.name             = "arboreal"
  s.version          = Arboreal::VERSION.dup
  s.platform         = Gem::Platform::RUBY
  s.required_ruby_version = ">= 1.8.7"
  s.summary          = "Efficient tree structures for ActiveRecord"
  s.description      = description
  s.author           = "Mike Williams"
  s.email            = "mdub@dogbiscuit.org"
  s.homepage         = "http://github.com/mdub/arboreal"
  s.require_path     = "lib"
  s.extra_rdoc_files = ["LICENSE","README.rdoc"]
  s.files            = Dir["lib/**/*", "spec/**/*", "Rakefile", *(s.extra_rdoc_files)]
  s.add_development_dependency("rspec", ">= 1.2.9")
end
