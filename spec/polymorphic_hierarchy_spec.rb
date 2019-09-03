require 'spec_helper'

describe "polymorphic hierarchy" do
  before do
    @red = RedNode.create!
    @green = GreenNode.create!(:parent => @red)
    @blue = BlueNode.create!(:parent => @green)
  end

  describe "#descendants" do
    it "includes nodes of other types" do
      expect(@red.descendants).to include(@green, @blue)
    end
  end

  describe "#subtree" do
    it "includes nodes of other types" do
      expect(@red.subtree).to include(@red, @green, @blue)
    end
  end

  describe "#ancestors" do
    it "includes nodes of other types" do
      expect(@blue.ancestors).to include(@red, @green)
    end
  end
end
