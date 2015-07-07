require 'arboreal'

class Node < ActiveRecord::Base
  acts_arboreal

  class Migration < ActiveRecord::Migration
    def self.up
      create_table "nodes", :force => true do |t|
        t.string "name"
        t.string "type"
        t.integer "parent_id"
        t.integer "root_id"
        t.string "materialized_path"
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
