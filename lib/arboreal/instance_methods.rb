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
      materialized_path.to_s.sub(/^-/, "").split("-").map { |x| x.to_i }
    end

    # return a scope matching all ancestors of this node
    def ancestors
      model_base_class.where(ancestor_conditions).order(:materialized_path)
    end

    # return a scope matching all descendants of this node
    def descendants
      model_base_class.where(descendant_conditions)
    end

    # return a scope matching all descendants of this node, AND the node itself
    def subtree
      model_base_class.where(subtree_conditions)
    end

    # return a scope matching all siblings of this node (NOT including the node itself)
    def siblings
      model_base_class.where(sibling_conditions)
    end

    # return whether or not this is a root of the tree
    def root?
      parent_id.nil?
    end

    # return the root of the tree
    def root
      return self if root?
      (root_relation_enabled? && root_ancestor) || ancestors.first
    end

    def ancestry_depth
      ancestor_ids.size
    end

    private

    def model_base_class
      self.class.base_class
    end

    def table_name
      self.class.table_name
    end

    def root_relation_enabled?
      self.class.reflect_on_association(:root_ancestor).present?
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
        self.root_ancestor     = parent ? parent.root : nil if root_relation_enabled?
        self.materialized_path = parent ? parent.path_string : "-"        
      end
    end

    def validate_parent_not_ancestor
      if persisted?
        if parent == self
          errors.add(:parent, "can't be the record itself")
        end
        if ancestor_ids.include?(id)
          errors.add(:parent, "can't be an ancestor")
        end
      end
    end

    def apply_ancestry_change_to_descendants
      if materialized_path_changed?
        old_path_string = "#{materialized_path_was}#{id}-"
        self.class
          .where("materialized_path like ?", old_path_string + "%")
          .update_all(descendant_attributes_to_update(old_path_string))
      end
    end

    def descendant_attributes_to_update(old_path_string)
      if root_relation_enabled?
        ["root_ancestor_id = ?, materialized_path = REPLACE(materialized_path, ?, ?)", root_ancestor_id, old_path_string, path_string]
      else
        ["materialized_path = REPLACE(materialized_path, ?, ?)", old_path_string, path_string]
      end
    end
  end
end
