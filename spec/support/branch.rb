require 'arboreal'

class Branch < ActiveRecord::Base
  acts_arboreal

  class Migration < ActiveRecord::Migration
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
