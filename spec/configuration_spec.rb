require "spec_helper"

describe "configuration of relations" do
  context "when `root` relation is enabled" do
    class CustomizedNode < ActiveRecord::Base
      self.table_name = 'nodes'
      acts_arboreal enable_root_relation:      true,
                    root_relation_options:     { touch: true },
                    parent_relation_options:   { touch: true },
                    children_relation_options: { autosave: true, dependent: :destroy }
    end

    it "allows the user to provide options to the has_many `children` relation" do
      expect(children_relation(CustomizedNode).options).to include(autosave: true)
      expect(children_relation(CustomizedNode).options).to include(dependent: :destroy)
    end

    it "allows the user to provide options to the belongs_to `parent` relation" do
      expect(parent_relation(CustomizedNode).options).to include(touch: true)
    end

    it "includes the `root_ancestor` relation" do
      expect(root_ancestor_relation(CustomizedNode)).not_to be_nil
    end

    it "allows the user to provide options to the belongs_to `root_ancestor` relation" do
      expect(root_ancestor_relation(CustomizedNode).options).to include(touch: true)
    end
  end

  context "when `root` relation is disabled" do
    class CustomizedBranch < ActiveRecord::Base
      self.table_name = 'branches'
      acts_arboreal parent_relation_options:   { touch: true },
                    children_relation_options: { dependent: :destroy }
    end

    it "allows the user to provide options to the has_many `children` relation" do
      expect(children_relation(CustomizedBranch).options).to include(dependent: :destroy)
    end

    it "allows the user to provide options to the belongs_to `parent` relation" do
      expect(parent_relation(CustomizedBranch).options).to include(touch: true)
    end

    it "does not include the `root_ancestor` relation" do
      expect(root_ancestor_relation(CustomizedBranch)).to be_nil
    end
  end

  def root_ancestor_relation(klass)
    reflections(klass)["root_ancestor"]
  end

  def parent_relation(klass)
    reflections(klass)["parent"]
  end

  def children_relation(klass)
    reflections(klass)["children"]
  end

  # In Rails 4.2, ActiveRecord::Base#reflections started being keyed by strings instead of symbols.
  def reflections(klass)
    klass.reflections.each_with_object({}) { |(key, value), memo| memo[key.to_s] = value }
  end
end
