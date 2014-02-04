#TODO -> Add transaction_id in loyalty_points_transactions

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

    #TODO -> Make this method private. Also check this in other classes also.
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