require "active_support/core_ext/string/filters"

module Arboreal
  module ClassMethods
    
    # Discard existing materialized_paths and recompute them from parent relationships.
    def rebuild_ancestry
      clear_materialized_paths
      populate_root_materialized_paths
      begin
        n_changes = extend_materialized_paths
      end until n_changes.zero?
      populate_root_relation if reflect_on_association(:root_ancestor)
    end
    
    private
    
    def clear_materialized_paths
      connection.update("UPDATE #{table_name} SET materialized_path = NULL")
    end

    def populate_root_materialized_paths
      connection.update("UPDATE #{table_name} SET materialized_path = '-' WHERE parent_id IS NULL")
    end

    def populate_root_relation
      if connection.adapter_name =~ /mysql/i
        connection.update(update_root_relation_sql)
      else
        roots.update_all(root_ancestor_id: nil)
        roots.find_each { |root| root.descendants.update_all(root_ancestor_id: root.id) }
      end
    end

    def update_root_relation_sql
      sql = <<-SQL
        UPDATE _arboreals_
        SET root_ancestor_id =
          IF(
            materialized_path = '-',
            NULL,
            SUBSTRING_INDEX(SUBSTRING_INDEX(materialized_path, '-', 2), '-', -1)
          )
      SQL
      sql.gsub("_arboreals_", table_name).squish
    end

    def extend_materialized_paths
      connection.update(ancestry_extension_sql)
    end

    # Return SQL that will extend materialized_paths one level further down the hierarchy.
    #
    # We use DBMS-specific SQL here, as string-concatenation operators vary.  
    # As a result, this *may* not work for DBMS that aren't explicitly supported.
    #
    def ancestry_extension_sql
      sql = if connection.adapter_name =~ /mysql/i
        <<-SQL
          UPDATE _arboreals_ AS child
          JOIN _arboreals_ AS parent ON parent.id = child.parent_id
          SET child.materialized_path = CONCAT(parent.materialized_path, parent.id, '-')
          WHERE child.materialized_path IS NULL
            AND parent.materialized_path IS NOT NULL
        SQL
      elsif connection.adapter_name == "JDBC" && connection.config[:url] =~ /sqlserver/
        <<-SQL
          UPDATE child
          SET child.materialized_path = (parent.materialized_path + CAST(parent.id AS varchar) + '-')
          FROM _arboreals_ AS child
          JOIN _arboreals_ AS parent ON parent.id = child.parent_id
          WHERE child.materialized_path IS NULL
            AND parent.materialized_path IS NOT NULL
        SQL
      else # SQLite, PostgreSQL, most others (SQL-92)
        <<-SQL
          UPDATE _arboreals_
          SET materialized_path = (
            SELECT (parent.materialized_path || _arboreals_.parent_id || '-')
            FROM _arboreals_ AS parent
            WHERE parent.id = _arboreals_.parent_id
              AND parent.materialized_path IS NOT NULL
          )
          WHERE materialized_path IS NULL
        SQL
      end
      sql.gsub("_arboreals_", table_name).squish
    end

  end
end
