#TODO ->  we can change column name updated_balance to balance.
#TODO ->  we can remove loyalty_points_awarded column from spree_order.
#TODO ->  Add indexes wherever required.
#TODO ->  Use Sti in credit or debit of loyalty_point
#TODO ->  update user balance in after creating loyalty_point transactions
module Spree
  class LoyaltyPointsTransaction < ActiveRecord::Base
    TRANSACTION_TYPES = ['Spree::LoyaltyPointsCreditTransaction', 'Spree::LoyaltyPointsDebitTransaction']
    CLASS_TO_TRANSACTION_TYPE = { 'Spree::LoyaltyPointsCreditTransaction' => 'Credit', 'Spree::LoyaltyPointsDebitTransaction' => 'Debit'}
    belongs_to :user
    belongs_to :source, polymorphic: true

    validates :loyalty_points, :numericality => { :only_integer => true, :message => Spree.t('validation.must_be_int'), :greater_than => 0 }
    validates :type, inclusion: { in: TRANSACTION_TYPES }
    validates :balance, presence: true
    validate :source_or_comment_present

    scope :for_order, ->(order) { where(source: order) }
    after_create :update_user_balance
    before_create :update_balance

    def source_or_comment_present
      unless source.present? || comment.present?
        errors.add :base, 'Source or Comment should be present'
      end
    end

    def transaction_type
      CLASS_TO_TRANSACTION_TYPE[type]
    end

  end
end