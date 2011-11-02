require 'active_record'

module Arboreal
  module ActiveRecordExtensions

    # Declares that this ActiveRecord::Base model has a tree-like structure.
    def acts_arboreal

      belongs_to :parent, :class_name => self.name
      has_many   :children, :class_name => self.name, :foreign_key => :parent_id

      extend Arboreal::ClassMethods
      include Arboreal::InstanceMethods

      before_validation :populate_ancestry_string

      validate do |record|
        record.send(:validate_parent_not_ancestor)
      end

      before_save :detect_ancestry_change
      after_save  :apply_ancestry_change_to_descendants

      case ActiveRecord::VERSION::MAJOR

      when 3
        scope :roots, where(:parent_id => nil)

      when 2
        named_scope :roots, {
          :conditions => ["parent_id IS NULL"]
        }

      end

    end

  end
end

ActiveRecord::Base.extend(Arboreal::ActiveRecordExtensions)
