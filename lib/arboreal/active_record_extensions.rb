module Arboreal
  module ActiveRecordExtensions
    
    def acts_arboreal

      belongs_to :parent, :class_name => self.name

      extend Arboreal::ClassMethods
      include Arboreal::InstanceMethods

      before_validation :populate_ancestry_string
      
    end
    
  end
end

require 'active_record'
ActiveRecord::Base.extend(Arboreal::ActiveRecordExtensions)
