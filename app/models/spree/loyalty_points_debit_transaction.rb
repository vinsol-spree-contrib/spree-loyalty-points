module Spree
  class LoyaltyPointsDebitTransaction < LoyaltyPointsTransaction

    #TODO -> update user's balance directly by one query instead of fetching the record and then save because it may save wrong value.
    def update_user_balance
      user.decrement(:loyalty_points_balance, loyalty_points)
      user.save!
    end

    def update_balance
      self.balance = user.loyalty_points_balance - loyalty_points
    end

  end
end