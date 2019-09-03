require 'active_record'

module CompatibleActiveRecord
  def when_active_record_version(current: -> {}, future: -> {})
    if ActiveRecord.gem_version >= Gem::Version.new("5.1")
      future.call
    else
      current.call
    end
  end
end
