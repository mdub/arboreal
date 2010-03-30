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
      self.class.base_class.scoped(:conditions => ["id in (?)", ancestor_ids], :order => [:ancestry_string])
    end
    
    private
    
    def populate_ancestry_string
      self.ancestry_string = (parent.path_string unless parent.nil?)
    end

  end
end
