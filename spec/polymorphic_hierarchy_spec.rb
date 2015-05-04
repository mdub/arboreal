require 'spec_helper'

describe "polymorphic hierarchy" do
  before do
    @red = RedNode.create!
    @green = GreenNode.create!(:parent => @red)
    @blue = BlueNode.create!(:parent => @green)
  end

  describe "#descendants" do
    it "includes nodes of other types" do
      @red.descendants.should include(@green, @blue)
    end
  end

  describe "#subtree" do
    it "includes nodes of other types" do
      @red.subtree.should include(@red, @green, @blue)
    end
  end

  describe "#ancestors" do
    it "includes nodes of other types" do
      @blue.ancestors.should include(@red, @green)
    end
  end
end
