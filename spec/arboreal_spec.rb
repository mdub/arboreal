require 'spec_helper'

require 'arboreal'

class Node < ActiveRecord::Base
  
  acts_arboreal
  
  class Migration < ActiveRecord::Migration

    def self.up
      create_table "nodes", :force => true do |t|
        t.string "name"
        t.integer "parent_id"
        t.string "ancestry_string"
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
    @victoria = Node.create!(:name => "Victoria", :parent => @australia)
    @melbourne = Node.create!(:name => "Melbourne", :parent => @victoria)
  end

  describe "root node" do
    
    describe "#parent" do
      it "returns nil" do
        @australia.parent.should == nil
      end
    end

    describe "#ancestors" do
      
      it "is empty" do
        @australia.ancestors.should be_empty
      end
      
    end
    
    describe "#ancestry_string" do
      it "is blank" do
        @australia.ancestry_string.should be_blank
      end
    end

    describe "#path_string" do
      it "contains only the id of the root" do
        @australia.path_string.should == "#{@australia.id},"
      end
    end
    
  end
  
  describe "child node" do

    describe "#parent" do
      it "returns the parent" do
        @melbourne.parent.should == @victoria
      end
    end
    
    describe "#ancestors" do
      it "returns all ancestors, depth-first" do
        @melbourne.ancestors.all.should == [@australia, @victoria]
      end
    end
    
  end

end


