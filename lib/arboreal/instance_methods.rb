module Arboreal
  module InstanceMethods

    def path_string
      "#{ancestry_string}#{id}-"
    end

    def ancestor_ids
      ancestry_string.sub(/^-/, "").split("-").map { |x| x.to_i }
    end
    
    def ancestors
      self.class.scoped(:conditions => ancestor_conditions, :order => [:ancestry_string])
    end

    def descendants
      self.class.scoped(:conditions => descendant_conditions)
    end
    
    def subtree
      self.class.scoped(:conditions => subtree_conditions)
    end
    
    def siblings
      self.class.scoped(:conditions => sibling_conditions)
    end

    def root
      ancestors.first || self
    end
    
    private

    def ancestor_conditions
      ["id in (?)", ancestor_ids]
    end

    def descendant_conditions
      ["#{self.class.table_name}.ancestry_string like ?", path_string + "%"]
    end

    def subtree_conditions
      [
        "#{self.class.table_name}.id = ? OR #{self.class.table_name}.ancestry_string like ?",
        id, path_string + "%"
      ]
    end
    
    def sibling_conditions
      [
        "#{self.class.table_name}.id <> ? AND #{self.class.table_name}.parent_id = ?",
        id, parent_id
      ]
    end

    def populate_ancestry_string
      self.class.send(:with_exclusive_scope) do
        self.ancestry_string = parent ? parent.path_string : "-"
      end
    end
    
    def validate_parent_not_ancestor
      if self.id 
        if parent_id == self.id
          errors.add(:parent, "can't be the record itself")
        end
        if ancestor_ids.include?(self.id)
          errors.add(:parent, "can't be an ancestor")
        end
      end
    end
    
    def detect_ancestry_change
      if ancestry_string_changed? && !new_record?
        old_path_string = "#{ancestry_string_was}#{id}-"
        @ancestry_change = [old_path_string, path_string]
      end
    end
    
    def apply_ancestry_change_to_descendants
      if @ancestry_change
        old_ancestry_string, new_ancestry_string = *@ancestry_change
        connection.update(<<-SQL.squish)
          UPDATE #{self.class.table_name} 
            SET ancestry_string = REPLACE(ancestry_string, '#{old_ancestry_string}', '#{new_ancestry_string}')
            WHERE ancestry_string LIKE '#{old_ancestry_string}%'
        SQL
        @ancestry_change = nil
      end
    end
    
  end
end
