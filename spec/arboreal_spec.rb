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
    @nsw = Node.create!(:name => "New South Wales", :parent => @australia)
    @sydney = Node.create!(:name => "Sydney", :parent => @nsw)
  end
  
  describe "node" do
  
    describe "#parent" do
      it "returns the parent" do
        @victoria.parent.should == @australia
      end
    end

    describe "#children" do
      it "returns the children" do
        @australia.children.to_set.should == [@victoria, @nsw].to_set
      end
    end

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
  
  describe "leaf node" do

    describe "#ancestry_string" do
      it "contains ids of all ancestors" do
        @melbourne.ancestry_string.should == "#{@australia.id},#{@victoria.id},"
      end
    end

    describe "#path_string" do
      it "contains ids of all ancestors, plus self" do
        @melbourne.path_string.should == "#{@australia.id},#{@victoria.id},#{@melbourne.id},"
      end
    end

    describe "#ancestors" do
      it "returns all ancestors, depth-first" do
        @melbourne.ancestors.all.should == [@australia, @victoria]
      end
    end

    describe "#children" do
      it "is empty" do
        @melbourne.children.should be_empty
      end
    end
    
  end

end


