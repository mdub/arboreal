module Arboreal
  module ClassMethods
    
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
      connection.update(<<-SQL.squish)
        UPDATE #{table_name}
        SET ancestry_string = 
          (SELECT (parent.ancestry_string || CAST(#{table_name}.parent_id AS varchar) || '-')
             FROM #{table_name} AS parent
            WHERE parent.id = #{table_name}.parent_id)
        WHERE ancestry_string IS NULL
      SQL
    end
    
  end
end
