require 'arboreal'
require_relative 'compatible_migration'

class Node < ActiveRecord::Base
  extend CompatibleMigration
  acts_arboreal enable_root_relation: true

  class Migration < base_migration_klass
    def self.up
      create_table "nodes", :force => true do |t|
        t.string "name"
        t.string "type"
        t.integer "parent_id"
        t.string "materialized_path"
        t.integer "root_ancestor_id"
      end
    end

    def self.down
      drop_table "nodes"
    end
  end
end

class RedNode < Node; end
class GreenNode < Node; end
class BlueNode < Node; end
