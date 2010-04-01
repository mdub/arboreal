module Arboreal
  module ActiveRecordExtensions
    
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
      
      named_scope :roots, {
        :conditions => ["parent_id IS NULL"]
      }
      
    end
    
  end
end

require 'active_record'
ActiveRecord::Base.extend(Arboreal::ActiveRecordExtensions)
