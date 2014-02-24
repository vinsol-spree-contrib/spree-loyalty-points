module Spree
  class LoyaltyPointsTransaction < ActiveRecord::Base
    include Spree::TransactionsTotalValidation
    TRANSACTION_TYPES = ['Spree::LoyaltyPointsCreditTransaction', 'Spree::LoyaltyPointsDebitTransaction']
    CLASS_TO_TRANSACTION_TYPE = { 'Spree::LoyaltyPointsCreditTransaction' => 'Credit', 'Spree::LoyaltyPointsDebitTransaction' => 'Debit'}
    belongs_to :user
    belongs_to :source, polymorphic: true

    validates :loyalty_points, :numericality => { :only_integer => true, :message => Spree.t('validation.must_be_int'), :greater_than => 0 }
    validates :type, inclusion: { in: TRANSACTION_TYPES }
    validates :balance, presence: true
    validate :source_or_comment_present
    validate :transactions_total_range, if: -> { source.present? && source.loyalty_points_transactions.present? }

    scope :for_order, ->(order) { where(source: order) }

    before_create :generate_transaction_id

    def transaction_type
      CLASS_TO_TRANSACTION_TYPE[type]
    end

    private

      def source_or_comment_present
        unless source.present? || comment.present?
          errors.add :base, 'Source or Comment should be present'
        end
      end

      def generate_transaction_id
        begin
          self.transaction_id = (Time.current.strftime("%s") + rand(999999).to_s).to(15)
        end while Spree::LoyaltyPointsTransaction.where(:transaction_id => transaction_id).present? 
      end

      def transactions_total_range
        validate_transactions_total_range(transaction_type, source)
      end

  end
end