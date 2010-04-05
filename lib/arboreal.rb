# Arboreal is yet another extension to ActiveRecord to support tree-shaped
# data structures.
#  
# Internally, Arboreal maintains a computed "ancestry_string" column, which
# caches the path from the root of a tree to each node, allowing efficient
# retrieval of both ancestors and descendants.
#  
# Arboreal surfaces relationships within the tree like +children+,
# +ancestors+, +descendants+, and +siblings+ as scopes, so that additional
# filtering/pagination can be performed.
#
module Arboreal
end

require 'arboreal/active_record_extensions'
require 'arboreal/class_methods'
require 'arboreal/instance_methods'
require 'arboreal/version'
