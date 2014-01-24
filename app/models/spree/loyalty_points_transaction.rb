module Spree
  class LoyaltyPointsTransaction < ActiveRecord::Base
    TRANSACTION_TYPES = ['Credit', 'Debit']
    belongs_to :user
    belongs_to :source, polymorphic: true

    validates :loyalty_points, :numericality => { :only_integer => true, :message => Spree.t('validation.must_be_int'), :greater_than => 0 }
    validates :transaction_type, inclusion: { in: TRANSACTION_TYPES }
    validates :updated_balance, presence: true
    validate :source_comment_presence

    def source_comment_presence
      unless source.present? || comment.present?
        errors.add :base, 'Source or Comment should be present'
      end
    end

    before_create :update_user_balance

    def update_user_balance
      if debit_transaction?
        user.decrement(:loyalty_points_balance, loyalty_points)
      else
        user.increment(:loyalty_points_balance, loyalty_points)
      end
      user.save!
      self.updated_balance = user.loyalty_points_balance
    end

    def debit_transaction?
      transaction_type == "Debit"
    end

  end
end