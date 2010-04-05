module Arboreal
  module ClassMethods
    
    # Discard existing ancestry_strings and recompute them from parent relationships.
    def rebuild_ancestry
      clear_ancestry_strings
      populate_root_ancestry_strings
      begin
        n_changes = extend_ancestry_strings 
      end until n_changes.zero?
    end
    
    private
    
    def clear_ancestry_strings
      connection.update("UPDATE #{table_name} SET ancestry_string = NULL")
    end

    def populate_root_ancestry_strings
      connection.update("UPDATE #{table_name} SET ancestry_string = '-' WHERE parent_id IS NULL")
    end

    def extend_ancestry_strings
      connection.update(ancestry_extension_sql)
    end

    def ancestry_extension_sql
      <<-SQL.squish.gsub("<table>", table_name)
        UPDATE <table>
        SET ancestry_string = 
          (SELECT (parent.ancestry_string || CAST(<table>.parent_id AS varchar) || '-')
             FROM <table> AS parent
            WHERE parent.id = <table>.parent_id)
        WHERE ancestry_string IS NULL
      SQL
    end
    
  end
end
