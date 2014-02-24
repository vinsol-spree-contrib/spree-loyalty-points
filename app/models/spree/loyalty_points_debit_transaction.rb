module Spree
  class LoyaltyPointsDebitTransaction < LoyaltyPointsTransaction

    #TODO -> Update conditions as discussed.

    after_create :update_user_balance
    before_create :update_balance

    private

      def update_user_balance
        user.decrement(:loyalty_points_balance, loyalty_points)
        user.save!
      end

      def update_balance
        self.balance = user.loyalty_points_balance - loyalty_points
      end

  end
end