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
      expect(@victoria.root_ancestor).to eq(@australia)
    end

    describe "#parent" do
      it "returns the parent" do
        expect(@victoria.parent).to eq(@australia)
      end
    end

    describe "#children" do
      it "returns the children" do
        expect(@australia.children.to_set).to eq([@victoria, @nsw].to_set)
      end
    end

    describe "#siblings" do
      it "returns other nodes with the same parent" do
        expect(@victoria.siblings).to eq([@nsw])
      end
    end

    it "cannot be it's own parent" do
      expect do
        @australia.update_attributes!(:parent => @australia)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "cannot be it's own ancestor" do
      expect do
        @australia.update_attributes!(:parent => @melbourne)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    describe "#ancestry_depth" do
      specify "root nodes are at depth 0" do
        expect(@australia.ancestry_depth).to eq(0)
      end

      specify "child nodes are one level deeper than their parents" do
        expect(@victoria.ancestry_depth).to eq(1)
        expect(@melbourne.ancestry_depth).to eq(2)
      end
    end

    describe "ancestry string format" do
      it "is valid" do
        expect(@australia).to be_valid
      end

      it "is not valid" do
        @australia.materialized_path = ''
        expect(@australia).not_to be_valid
        @australia.materialized_path = '42'
        expect(@australia).not_to be_valid
        @australia.materialized_path = '42-'
        expect(@australia).not_to be_valid
        @australia.materialized_path = '--'
        expect(@australia).not_to be_valid
        @australia.materialized_path = '-42'
        expect(@australia).not_to be_valid
        @australia.materialized_path = '-42-58'
        expect(@australia).not_to be_valid
        @australia.materialized_path = 'not ids'
        expect(@australia).not_to be_valid
        @australia.materialized_path = '\''
        expect(@australia).not_to be_valid
        @australia.materialized_path = '; drop table nodes'
        expect(@australia).not_to be_valid
      end
    end
  end

  describe "root node" do
    it "is a root" do
      expect(@australia).to be_root
    end

    it "does not have a `root_ancestor`" do
      expect(@australia.root_ancestor).to be_nil
    end

    describe "#parent" do
      it "returns nil" do
        expect(@australia.parent).to eq(nil)
      end
    end

    describe "#ancestors" do
      it "is empty" do
        expect(@australia.ancestors).to be_empty
      end
    end

    describe "#materialized_path" do
      it "is a single dash" do
        expect(@australia.materialized_path).to eq("-")
      end
    end

    describe "#path_string" do
      it "contains only the id of the root" do
        expect(@australia.path_string).to eq("-#{@australia.id}-")
      end

      it "returns '-' for new records" do
        expect(Node.new.path_string).to eq("-")
      end
    end

    describe "#descendants" do
      it "includes children" do
        expect(@australia.descendants).to include(@victoria)
        expect(@australia.descendants).to include(@nsw)
      end

      it "includes grand-children" do
        expect(@australia.descendants).to include(@melbourne)
        expect(@australia.descendants).to include(@sydney)
      end

      it "excludes self" do
        expect(@australia.descendants).not_to include(@australia)
      end
    end

    describe "#subtree" do
      it "includes children" do
        expect(@australia.subtree).to include(@victoria)
        expect(@australia.subtree).to include(@nsw)
      end

      it "includes grand-children" do
        expect(@australia.subtree).to include(@melbourne)
        expect(@australia.subtree).to include(@sydney)
      end

      it "includes self" do
        expect(@australia.subtree).to include(@australia)
      end
    end

    describe "#root" do
      it "is itself" do
        expect(@australia.root).to eq(@australia)
      end
    end
  end

  describe "leaf node" do
    it "is not a root" do
      expect(@melbourne).not_to be_root
    end

    it "has a `root_ancestor`" do
      expect(@melbourne.root_ancestor).to eq(@australia)
    end

    describe "#materialized_path" do
      it "contains ids of all ancestors" do
        expect(@melbourne.materialized_path).to eq("-#{@australia.id}-#{@victoria.id}-")
      end
    end

    describe "#path_string" do
      it "contains ids of all ancestors, plus self" do
        expect(@melbourne.path_string).to eq("-#{@australia.id}-#{@victoria.id}-#{@melbourne.id}-")
      end
    end

    describe "#ancestors" do
      it "returns all ancestors, depth-first" do
        expect(@melbourne.ancestors.all).to eq([@australia, @victoria])
      end
    end

    describe "#children" do
      it "returns an empty collection" do
        expect(@melbourne.children).to be_empty
      end
    end

    describe "#descendants" do
      it "returns an empty collection" do
        expect(@melbourne.children).to be_empty
      end
    end

    describe "#root" do
      it "is the root of the tree" do
        expect(@melbourne.root).to eq(@australia)
      end
    end
  end

  describe ".roots" do
    it "returns root nodes" do
      @nz = Node.create!(:name => "New Zealand")
      expect(Node.roots.to_set).to eq([@australia, @nz].to_set)
    end
  end

  describe "when a node changes parent" do
    before do
      @box_hill = Node.create!(:name => "Box Hill", :parent => @melbourne)
      @nz = Node.create!(:name => "New Zealand")
      @victoria.update_attributes!(:parent => @nz)
    end

    it "updates it's root ancestor" do
      expect(@victoria.reload.root_ancestor).to eq(@nz)
    end

    describe "each descendant" do
      it "follows" do
        @melbourne.reload
        expect(@melbourne.root_ancestor).to eq(@nz)
        expect(@melbourne.ancestors).to include(@nz, @victoria)
        expect(@melbourne.ancestors).not_to include(@australia)

        @box_hill.reload
        expect(@box_hill.root_ancestor).to eq(@nz)
        expect(@box_hill.ancestors).to include(@nz, @victoria, @melbourne)
        expect(@box_hill.ancestors).not_to include(@australia)
      end
    end
  end

  describe "when a node becomes a root" do
    before do
      Node.create!(:name => "Southbank", :parent => @melbourne)
      @victoria.update_attribute(:parent_id, nil)
    end

    it "no longer has ancestors" do
      expect(@victoria.ancestors).to be_empty
    end

    it "no longer has a `root_ancestor`" do
      expect(@victoria.reload.root_ancestor).to be_nil
    end

    it "persists changes to the ancestors" do
      expect(@victoria.reload.ancestors).to be_empty
    end

    it 'updates the root of its descendants' do
      expect(@victoria.descendants.map(&:root_ancestor).uniq).to eq([@victoria])
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
      expect(@tasmania.root_ancestor).to eq(@australia)
    end

    it "still has the right ancestry" do
      expect(@tasmania.ancestors).to eq([@australia])
    end
  end

  describe "SQL injection protection" do
    before do
      @melbourne.materialized_path = 'EVIL \'"SQL INJECTION'
    end

    it 'does not cause a SQL injection' do
      expect {
        @melbourne.save(validate: false)
      }.not_to raise_error
    end
  end

  describe ".rebuild_ancestry" do
    context "when root relation is enabled" do
      before do
        Node.connection.update("UPDATE nodes SET materialized_path = 'corrupt', root_ancestor_id = 0")
        Node.rebuild_ancestry
      end

      it "re-populates the `foreign_key` for the `root_ancestor` relation" do
        expect(@australia.reload.root_ancestor_id).to be_nil
        expect(@melbourne.reload.root_ancestor_id).to eq(@australia.id)
        expect(@victoria.reload.root_ancestor_id).to eq(@australia.id)
      end

      it "re-populates all materialized_paths" do
        expect(Node.where(materialized_path: 'corrupt').count).to eq(0)
      end

      it "fixes the hierarchy" do
        expect(@melbourne.reload.ancestors).to eq([@australia, @victoria])
        expect(@sydney.reload.ancestors).to eq([@australia, @nsw])
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
        expect(Branch.where(materialized_path: 'corrupt').count).to eq(0)
      end

      it "fixes the hierarchy" do
        expect(@child.reload.ancestors).to eq([@grandparent])
        expect(@grandchild.reload.ancestors).to eq([@grandparent, @child])
      end
    end
  end

  describe "a newly-created node" do
    let(:new_node) { Node.new(name: "New node") }

    it "has no ancestor ids" do
      expect(new_node.ancestor_ids).to be_empty
    end
  end

  describe "root" do
    context "when root relation is enabled" do
      context "when root_ancestor_id is nil" do
        before { @melbourne.root_ancestor_id = nil }

        it "fetches the root from its `ancestors`" do
          expect(@melbourne).to receive(:ancestors) { [@australia, @victoria] }
          expect(@melbourne.root).to eq(@australia)
        end
      end

      context "when root_ancestor_id is not nil" do
        it "fetches the root from the root_ancestor relation" do
          expect(@melbourne).not_to receive(:ancestors)
          expect(@melbourne.root).to eq(@australia)
        end
      end
    end

    context "when root relation is disabled" do
      before do
        @grandparent = Branch.create!(name: 'Parent')
        @child       = @grandparent.children.create!(name: 'Child')
      end

      it "fetches the root from its `ancestors`" do
        expect(@child).to receive(:ancestors) { [@grandparent] }
        expect(@child.root).to eq(@grandparent)
      end
    end
  end
end
