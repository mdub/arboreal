require "spec_helper"

describe "Arboreal hierarchy" do
  before do
    @australia = Node.create!(:name => "Australia")
    @victoria = @australia.children.create!(:name => "Victoria")
    @melbourne = @victoria.children.create!(:name => "Melbourne")
    @nsw = @australia.children.create!(:name => "New South Wales")
    @sydney = @nsw.children.create!(:name => "Sydney")
  end

  describe "node" do
    it "has a `root_ancestor`" do
      @victoria.root_ancestor.should == @australia
    end

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

    describe "#siblings" do
      it "returns other nodes with the same parent" do
        @victoria.siblings.should == [@nsw]
      end
    end

    it "cannot be it's own parent" do
      lambda do
        @australia.update_attributes!(:parent => @australia)
      end.should raise_error(ActiveRecord::RecordInvalid)
    end

    it "cannot be it's own ancestor" do
      lambda do
        @australia.update_attributes!(:parent => @melbourne)
      end.should raise_error(ActiveRecord::RecordInvalid)
    end

    describe "#ancestry_depth" do
      specify "root nodes are at depth 0" do
        @australia.ancestry_depth.should == 0
      end

      specify "child nodes are one level deeper than their parents" do
        @victoria.ancestry_depth.should == 1
        @melbourne.ancestry_depth.should == 2
      end
    end

    describe "ancestry string format" do
      it "is valid" do
        @australia.should be_valid
      end

      it "is not valid" do
        @australia.materialized_path = ''
        @australia.should_not be_valid
        @australia.materialized_path = '42'
        @australia.should_not be_valid
        @australia.materialized_path = '42-'
        @australia.should_not be_valid
        @australia.materialized_path = '--'
        @australia.should_not be_valid
        @australia.materialized_path = '-42'
        @australia.should_not be_valid
        @australia.materialized_path = '-42-58'
        @australia.should_not be_valid
        @australia.materialized_path = 'not ids'
        @australia.should_not be_valid
        @australia.materialized_path = '\''
        @australia.should_not be_valid
        @australia.materialized_path = '; drop table nodes'
        @australia.should_not be_valid
      end
    end
  end

  describe "root node" do
    it "is a root" do
      @australia.should be_root
    end

    it "does not have a `root_ancestor`" do
      @australia.root_ancestor.should be_nil
    end

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

    describe "#materialized_path" do
      it "is a single dash" do
        @australia.materialized_path.should == "-"
      end
    end

    describe "#path_string" do
      it "contains only the id of the root" do
        @australia.path_string.should == "-#{@australia.id}-"
      end

      it "returns '-' for new records" do
        Node.new.path_string.should == "-"
      end
    end

    describe "#descendants" do
      it "includes children" do
        @australia.descendants.should include(@victoria)
        @australia.descendants.should include(@nsw)
      end

      it "includes grand-children" do
        @australia.descendants.should include(@melbourne)
        @australia.descendants.should include(@sydney)
      end

      it "excludes self" do
        @australia.descendants.should_not include(@australia)
      end
    end

    describe "#subtree" do
      it "includes children" do
        @australia.subtree.should include(@victoria)
        @australia.subtree.should include(@nsw)
      end

      it "includes grand-children" do
        @australia.subtree.should include(@melbourne)
        @australia.subtree.should include(@sydney)
      end

      it "includes self" do
        @australia.subtree.should include(@australia)
      end
    end

    describe "#root" do
      it "is itself" do
        @australia.root.should == @australia
      end
    end
  end

  describe "leaf node" do
    it "is not a root" do
      @melbourne.should_not be_root
    end

    it "has a `root_ancestor`" do
      @melbourne.root_ancestor.should == @australia
    end

    describe "#materialized_path" do
      it "contains ids of all ancestors" do
        @melbourne.materialized_path.should == "-#{@australia.id}-#{@victoria.id}-"
      end
    end

    describe "#path_string" do
      it "contains ids of all ancestors, plus self" do
        @melbourne.path_string.should == "-#{@australia.id}-#{@victoria.id}-#{@melbourne.id}-"
      end
    end

    describe "#ancestors" do
      it "returns all ancestors, depth-first" do
        @melbourne.ancestors.all.should == [@australia, @victoria]
      end
    end

    describe "#children" do
      it "returns an empty collection" do
        @melbourne.children.should be_empty
      end
    end

    describe "#descendants" do
      it "returns an empty collection" do
        @melbourne.children.should be_empty
      end
    end

    describe "#root" do
      it "is the root of the tree" do
        @melbourne.root.should == @australia
      end
    end
  end

  describe ".roots" do
    it "returns root nodes" do
      @nz = Node.create!(:name => "New Zealand")
      Node.roots.to_set.should == [@australia, @nz].to_set
    end
  end

  describe "when a node changes parent" do
    before do
      @box_hill = Node.create!(:name => "Box Hill", :parent => @melbourne)
      @nz = Node.create!(:name => "New Zealand")
      @victoria.update_attributes!(:parent => @nz)
    end

    it "updates it's root ancestor" do
      @victoria.reload.root_ancestor.should == @nz
    end

    describe "each descendant" do
      it "follows" do
        @melbourne.reload
        @melbourne.root_ancestor.should == @nz
        @melbourne.ancestors.should include(@nz, @victoria)
        @melbourne.ancestors.should_not include(@australia)

        @box_hill.reload
        @box_hill.root_ancestor.should == @nz
        @box_hill.ancestors.should include(@nz, @victoria, @melbourne)
        @box_hill.ancestors.should_not include(@australia)
      end
    end
  end

  describe "when a node becomes a root" do
    before do
      Node.create!(:name => "Southbank", :parent => @melbourne)
      @victoria.update_attribute(:parent_id, nil)
    end

    it "no longer has ancestors" do
      @victoria.ancestors.should be_empty
    end

    it "no longer has a `root_ancestor`" do
      @victoria.reload.root_ancestor.should be_nil
    end

    it "persists changes to the ancestors" do
      @victoria.reload.ancestors.should be_empty
    end

    it 'updates the root of its descendants' do
      @victoria.descendants.map(&:root_ancestor).uniq.should == [@victoria]
    end
  end

  describe "node created using find_or_create_by" do
    before do
      if Gem.loaded_specs['activerecord'].version >= Gem::Version.create('4.0')
        @tasmania = @australia.children.find_or_create_by(name: "Tasmania")
      else
        @tasmania = @australia.children.find_or_create_by_name("Tasmania")
      end
    end

    it "has the correct `root_ancestor`" do
      @tasmania.root_ancestor.should == @australia
    end

    it "still has the right ancestry" do
      @tasmania.ancestors.should == [@australia]
    end
  end

  describe "SQL injection protection" do
    before do
      @melbourne.materialized_path = 'EVIL \'"SQL INJECTION'
    end

    it 'does not cause a SQL injection' do
      lambda {
        @melbourne.save(validate: false)
      }.should_not raise_error
    end
  end

  describe ".rebuild_ancestry" do
    context "when root relation is enabled" do
      before do
        Node.connection.update("UPDATE nodes SET materialized_path = 'corrupt', root_ancestor_id = 0")
        Node.rebuild_ancestry
      end

      it "re-populates the `foreign_key` for the `root_ancestor` relation" do
        @australia.reload.root_ancestor_id.should be_nil
        @melbourne.reload.root_ancestor_id.should == @australia.id
        @victoria.reload.root_ancestor_id.should == @australia.id
      end

      it "re-populates all materialized_paths" do
        Node.where(materialized_path: 'corrupt').count.should == 0
      end

      it "fixes the hierarchy" do
        @melbourne.reload.ancestors.should == [@australia, @victoria]
        @sydney.reload.ancestors.should == [@australia, @nsw]
      end
    end

    context "when root relation is disabled" do
      before do
        @grandparent = Branch.create!(name: "Root")
        @child       = @grandparent.children.create!(name: "Child")
        @grandchild  = @child.children.create!(name: "Grandchild")

        Branch.connection.update("UPDATE nodes SET materialized_path = 'corrupt'")
        Branch.rebuild_ancestry
      end

      it "re-populates all materialized_paths" do
        Branch.where(materialized_path: 'corrupt').should have(0).items
      end

      it "fixes the hierarchy" do
        @child.reload.ancestors.should == [@grandparent]
        @grandchild.reload.ancestors.should == [@grandparent, @child]
      end
    end
  end

  describe "a newly-created node" do
    let(:new_node) { Node.new(name: "New node") }

    it "has no ancestor ids" do
      new_node.ancestor_ids.should be_empty
    end
  end

  describe "root" do
    context "when root relation is enabled" do
      context "when root_ancestor_id is nil" do
        before { @melbourne.root_ancestor_id = nil }

        it "fetches the root from its `ancestors`" do
          @melbourne.should_receive(:ancestors) { [@australia, @victoria] }
          @melbourne.root.should == @australia
        end
      end

      context "when root_ancestor_id is not nil" do
        it "fetches the root from the root_ancestor relation" do
          @melbourne.should_not_receive(:ancestors)
          @melbourne.root.should == @australia
        end
      end
    end

    context "when root relation is disabled" do
      before do
        @grandparent = Branch.create!(name: 'Parent')
        @child       = @grandparent.children.create!(name: 'Child')
      end

      it "fetches the root from its `ancestors`" do
        @child.should_receive(:ancestors) { [@grandparent] }
        @child.root.should == @grandparent
      end
    end
  end
end
