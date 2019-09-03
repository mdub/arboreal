require 'arboreal'
require_relative 'compatible_migration'

class Branch < ActiveRecord::Base
  extend CompatibleMigration
  acts_arboreal

  class Migration < base_migration_klass
    def self.up
      create_table "branches", :force => true do |t|
        t.string  "name"
        t.integer "parent_id"
        t.string  "materialized_path"
      end
    end

    def self.down
      drop_table "branches"
    end
  end
end
