module Spree
  class LoyaltyPointsCreditTransaction < LoyaltyPointsTransaction

    #TODO -> I think we have not test this method on these conditions. Please check.
    validate :positive_loyalty_points_total, if: -> { source.present? && !source.loyalty_points_used? && source.loyalty_points_credit_transactions.present? }

    after_create :update_user_balance
    before_create :update_balance

    private

      def update_user_balance
        user.increment(:loyalty_points_balance, loyalty_points)
        user.save!
      end

      def update_balance
        self.balance = user.loyalty_points_balance + loyalty_points
      end

      def positive_loyalty_points_total
        positive_total = source.loyalty_points_credit_transactions.sum(:loyalty_points) + loyalty_points
        negative_total = source.loyalty_points_debit_transactions.sum(:loyalty_points)
        if negative_total > positive_total
          errors.add :base, 'Loyalty Points Total cannot be negative for this source'
        end
      end

  end
end