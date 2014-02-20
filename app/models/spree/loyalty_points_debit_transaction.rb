module Spree
  class LoyaltyPointsDebitTransaction < LoyaltyPointsTransaction

    validate :negative_loyalty_points_total, if: -> { source.present? && source.loyalty_points_used? && source.loyalty_points_debit_transactions.present? }

    after_create :update_user_balance
    before_create :update_balance

    private

      #TODO -> update user's balance directly by one query instead of fetching the record and then save because it may save wrong value.
      def update_user_balance
        user.decrement(:loyalty_points_balance, loyalty_points)
        user.save!
      end

      def update_balance
        self.balance = user.loyalty_points_balance - loyalty_points
      end

      def negative_loyalty_points_total
        positive_total = source.loyalty_points_credit_transactions.sum(:loyalty_points)
        negative_total = source.loyalty_points_debit_transactions.sum(:loyalty_points) + loyalty_points
        if negative_total < positive_total
          errors.add :base, 'Loyalty Points Total cannot be positive for this source'
        end
      end

  end
end