require 'active_record'
require 'arboreal/compatible_active_record'

module CompatibleMigration
  include Arboreal::CompatibleActiveRecord

  def base_migration_klass
    when_active_record_version(
      current: -> { ActiveRecord::Migration },
      future: -> { ActiveRecord::Migration[4.2] }
    )
  end
end
