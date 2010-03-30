require 'spec_helper'

require 'arboreal'

class Node < ActiveRecord::Base
  
  acts_arboreal
  
  class Migration < ActiveRecord::Migration

    def self.up
      create_table "nodes", :force => true do |t|
        t.string "name"
        t.integer "parent_id"
        t.integer "ancestor_id_string"
      end
    end

    def self.down
      drop_table "nodes"
    end

  end
  
end

describe "{Arboreal}" do

  before(:all) do
    Node::Migration.up
  end
  
  after(:all) do
    Node::Migration.down
  end
  
  before do
    @australia = Node.create!(:name => "Australia")
  end

  describe "root node" do
    
    describe "#parent" do
      it "returns nil" do
        @australia.parent.should == nil
      end
    end
    
  end

end


