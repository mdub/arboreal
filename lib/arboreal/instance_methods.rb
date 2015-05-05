require "active_support/core_ext/string/filters"

module Arboreal
  module InstanceMethods

    def path_string
      if new_record?
        "-"
      else
        "#{materialized_path}#{id}-"
      end
    end

    def ancestor_ids
      materialized_path.sub(/^-/, "").split("-").map { |x| x.to_i }
    end

    # return a scope matching all ancestors of this node
    def ancestors
      model_base_class.scoped(:conditions => ancestor_conditions, :order => :materialized_path)
    end

    # return a scope matching all descendants of this node
    def descendants
      model_base_class.scoped(:conditions => descendant_conditions)
    end

    # return a scope matching all descendants of this node, AND the node itself
    def subtree
      model_base_class.scoped(:conditions => subtree_conditions)
    end

    # return a scope matching all siblings of this node (NOT including the node itself)
    def siblings
      model_base_class.scoped(:conditions => sibling_conditions)
    end

    # return the root of the tree
    def root
      ancestors.first || self
    end

    private

    def model_base_class
      self.class.base_class
    end

    def table_name
      self.class.table_name
    end

    def ancestor_conditions
      ["id in (?)", ancestor_ids]
    end

    def descendant_conditions
      ["#{table_name}.materialized_path LIKE ?", path_string + "%"]
    end

    def subtree_conditions
      [
        "#{table_name}.id = ? OR #{table_name}.materialized_path LIKE ?",
        id, path_string + "%"
      ]
    end

    def sibling_conditions
      [
        "#{table_name}.id <> ? AND #{table_name}.parent_id = ?",
        id, parent_id
      ]
    end

    def populate_materialized_path
      if parent_id_changed? || materialized_path.nil?
        model_base_class.send(:with_exclusive_scope) do
          self.materialized_path = parent ? parent.path_string : "-"
        end
      end
    end

    def validate_parent_not_ancestor
      if self.id
        if parent == self
          errors.add(:parent, "can't be the record itself")
        end
        if ancestor_ids.include?(self.id)
          errors.add(:parent, "can't be an ancestor")
        end
      end
    end

    def apply_ancestry_change_to_descendants
      if materialized_path_changed? && persisted?
        old_path_string = "#{materialized_path_was}#{id}-"
        self.class
          .where("materialized_path like ?", old_path_string + "%")
          .update_all ["materialized_path = REPLACE(materialized_path, ?, ?)", old_path_string, path_string]
      end
    end
  end
end
