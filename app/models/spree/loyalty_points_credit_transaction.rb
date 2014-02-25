module Spree
  class LoyaltyPointsCreditTransaction < LoyaltyPointsTransaction

    #TODO -> I think we have not test this method on these conditions. Please check.
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

  end
end