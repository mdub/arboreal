require "spec_helper"

describe "saving dependent objects" do
  let(:parent) { Node.new(name: "Parent") }
  let(:child) { Node.new(name: "Child") }

  it "when no parent_id is present, but parent is nil" do
    child.parent_id = 12345
    child.parent.should be_nil
    child.save!

    child.materialized_path.should eq("-")
  end

  context "when the parent has not been saved" do
    context "and the child has not been saved" do
      context "when the child is saved" do
        before do
          child.parent = parent
          child.save!
        end

        it "also saves the parent" do
          parent.should be_persisted
        end

        it "updates the child's `root_ancestor`" do
          child.root_ancestor.should == parent
        end

        it "updates the child's materialized path" do
          child.materialized_path.should eq(parent.path_string)
        end
      end

      context "when the parent is saved" do
        before do
          parent.children << child
          parent.save!
          child.reload
        end

        it "also saves the child" do
          child.should be_persisted
        end

        it "updates the child's `root_ancestor`" do
          child.root_ancestor.should == parent
        end

        it "updates the child's materialized path" do
          child.materialized_path.should eq(parent.path_string)
        end
      end
    end

    context "and the child had been saved" do
      before do
        child.save!
      end

      context "when the child is saved with its new parent" do
        before do
          child.parent = parent
          child.save!
        end

        it "also saves the parent" do
          parent.should be_persisted
        end

        it "updates the child's `root_ancestor`" do
          child.root_ancestor.should == parent
        end

        it "updates the child's materialized path" do
          child.materialized_path.should eq(parent.path_string)
        end
      end

      context "when the parent is saved" do
        before do
          parent.children << child
          parent.save!
          parent.reload

          child.reload
        end

        it "updates the child's `root_ancestor`" do
          child.root_ancestor.should == parent
        end

        it "updates the child's materialized path" do
          child.materialized_path.should eq(parent.path_string)
        end
      end
    end

    context "and the child had been saved with a different parent" do
      let(:original_parent) { Node.create!(name: "Original parent") }

      before do
        child.parent = original_parent
        child.save!
      end

      context "when the child is saved with its new parent" do
        before do
          child.parent = parent
          child.save!
        end

        it "also saves the new parent" do
          parent.should be_persisted
        end

        it "updates the child's `root_ancestor`" do
          child.root_ancestor.should == parent
        end

        it "updates the child's materialized path" do
          child.materialized_path.should eq(parent.path_string)
        end
      end

      context "when the parent is saved" do
        before do
          parent.children << child
          parent.save!
          parent.reload

          child.reload
        end

        it "updates the child's `root_ancestor`" do
          child.root_ancestor.should == parent
        end

        it "updates the child's materialized path" do
          child.materialized_path.should eq(parent.path_string)
        end
      end
    end
  end

  context "when the parent has been saved" do
    before do
      parent.save!
    end

    context "and the child has not been saved" do
      context "when the child is saved" do
        before do
          child.parent = parent
          child.save!
          child.reload
        end

        it "updates the child's `root_ancestor`" do
          child.root_ancestor.should == parent
        end

        it "updates the child's materialized path" do
          child.materialized_path.should eq(parent.path_string)
        end
      end

      context "when the parent gains a new child" do
        before do
          parent.children << child
          child.reload
        end

        it "saves the child" do
          child.should be_persisted
        end

        it "updates the child's `root_ancestor`" do
          child.root_ancestor.should == parent
        end

        it "updates the child's materialized path" do
          child.materialized_path.should eq(parent.path_string)
        end
      end
    end
  end
end

