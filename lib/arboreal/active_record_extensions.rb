module Arboreal
  
  module ActiveRecordExtensions
    
    def acts_arboreal
      belongs_to :parent, :class_name => self.name
    end
    
  end
  
end

require 'active_record'
ActiveRecord::Base.extend(Arboreal::ActiveRecordExtensions)
