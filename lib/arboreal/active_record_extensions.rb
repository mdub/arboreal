require 'active_record'

module Arboreal
  module ActiveRecordExtensions
    # Declares that this ActiveRecord::Base model has a tree-like structure.
    def acts_arboreal(options = {})
      belongs_to :parent, class_name: self.name
      has_many   :children, { class_name: self.name, foreign_key: :parent_id, inverse_of: :parent }
                              .reverse_merge(options[:children_relation_options] || {})

      extend Arboreal::ClassMethods
      include Arboreal::InstanceMethods

      before_validation :populate_materialized_path
      before_save :populate_materialized_path

      validate :validate_parent_not_ancestor
      validates :materialized_path, format: { with: /\A-(\d+-)*\z/, allow_nil: false, allow_blank: false }

      after_save  :apply_ancestry_change_to_descendants

      scope :roots, lambda { where(parent_id: nil) }
    end
  end
end

ActiveRecord::Base.extend(Arboreal::ActiveRecordExtensions)
