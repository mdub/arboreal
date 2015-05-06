require "spec_helper"

describe "configuration of relations" do
  class CustomizedNode < ActiveRecord::Base
    self.table_name = 'nodes'
    acts_arboreal parent_relation_options: { touch: true },
                  children_relation_options: { autosave: true, dependent: :destroy }
  end

  it 'allows the user to provide options to the has_many relation' do
    children_relation.options.should include(autosave: true)
    children_relation.options.should include(dependent: :destroy)
  end

  it "allows the user to provide options to the belongs_to relation" do
    parent_relation.options.should include(touch: true)
  end

  def parent_relation
    reflections(CustomizedNode)["parent"]
  end

  def children_relation
    reflections(CustomizedNode)["children"]
  end

  # In Rails 4.2, ActiveRecord::Base#reflections started being keyed by strings instead of symbols.
  def reflections(klass)
    klass.reflections.each_with_object({}) { |(key, value), memo| memo[key.to_s] = value }
  end
end
