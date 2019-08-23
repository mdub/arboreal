require 'active_record'

module CompatibleMigration
  def base_migration_klass
    ActiveRecord.gem_version > Gem::Version.new("5.1") ?
      ActiveRecord::Migration[4.2] : ActiveRecord::Migration
  end
end
