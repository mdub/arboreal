require 'active_record'
require 'compatible_active_record'

module CompatibleMigration
  include CompatibleActiveRecord

  def base_migration_klass
    when_active_record_version(
      current: -> { ActiveRecord::Migration },
      future: -> { ActiveRecord::Migration[4.2] }
    )
  end
end
