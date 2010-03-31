module Arboreal
  module InstanceMethods

    def path_string
      "#{ancestry_string}#{id},"
    end

    def ancestry_string
      read_attribute(:ancestry_string) || ""
    end

    def ancestor_ids
      ancestry_string.split(",").map { |x| x.to_i }
    end

    def ancestors
      base_class.scoped(
      :conditions => ["id in (?)", ancestor_ids], 
      :order => [:ancestry_string]
      )
    end

    def descendants
      ancestry_pattern = 
      base_class.scoped(
      :conditions => ["#{base_class.table_name}.ancestry_string like ?", path_string + "%"]
      )
    end

    def subtree
      ancestry_pattern = path_string + "%"
      base_class.scoped(
      :conditions => [
        "#{base_class.table_name}.id = ? OR #{base_class.table_name}.ancestry_string like ?",
        id, path_string + "%"
      ]
      )
    end

    private

    def base_class
      self.class.base_class
    end

    def populate_ancestry_string
      self.ancestry_string = (parent.path_string unless parent.nil?)
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
    
  end
end
