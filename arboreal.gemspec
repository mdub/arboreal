description = <<TEXT
Arboreal is yet another extension to ActiveRecord to support tree-shaped data structures.

Internally, Arboreal maintains a computed "ancestry_string" column, which caches the path from the root of
a tree to each node, allowing efficient retrieval of both ancestors and descendants.

Arboreal surfaces relationships within the tree like "children", "ancestors", "descendants", and "siblings"
as scopes, so that additional filtering/pagination can be performed.
TEXT

$: << File.expand_path("../lib", __FILE__)
require "arboreal/version"

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
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.rdoc_options     = ["--title", "Arboreal", "--main", "README.rdoc"]
  s.require_path     = "lib"
  s.files            = Dir["lib/**/*", "spec/**/*", "Rakefile"] + s.extra_rdoc_files
  s.add_runtime_dependency("activerecord", "~> 3.0")
  s.add_runtime_dependency("activesupport", "~> 3.0")
end
