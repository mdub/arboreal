require "active_support/core_ext/string/filters"

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

    # Return SQL that will extend ancestry_strings one level further down the hierarchy.
    #
    # We use DBMS-specific SQL here, as string-concatenation operators vary.  
    # As a result, this *may* not work for DBMS that aren't explicitly supported.
    #
    def ancestry_extension_sql
      sql = if connection.adapter_name =~ /mysql/i
        <<-SQL
          UPDATE _arboreals_ AS child
          JOIN _arboreals_ AS parent ON parent.id = child.parent_id
          SET child.ancestry_string = CONCAT(parent.ancestry_string, parent.id, '-')
          WHERE child.ancestry_string IS NULL
            AND parent.ancestry_string IS NOT NULL
        SQL
      elsif connection.adapter_name == "JDBC" && connection.config[:url] =~ /sqlserver/
        <<-SQL
          UPDATE child
          SET child.ancestry_string = (parent.ancestry_string + CAST(parent.id AS varchar) + '-')
          FROM _arboreals_ AS child
          JOIN _arboreals_ AS parent ON parent.id = child.parent_id
          WHERE child.ancestry_string IS NULL
            AND parent.ancestry_string IS NOT NULL
        SQL
      else # SQLite, PostgreSQL, most others (SQL-92)
        <<-SQL
          UPDATE _arboreals_
          SET ancestry_string = (
            SELECT (parent.ancestry_string || _arboreals_.parent_id || '-')
            FROM _arboreals_ AS parent
            WHERE parent.id = _arboreals_.parent_id
              AND parent.ancestry_string IS NOT NULL
          )
          WHERE ancestry_string IS NULL
        SQL
      end
      sql.gsub("_arboreals_", table_name).squish
    end

  end
end
