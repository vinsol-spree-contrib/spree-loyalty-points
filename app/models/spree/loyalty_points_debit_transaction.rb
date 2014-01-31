module Spree
  class LoyaltyPointsDebitTransaction < LoyaltyPointsTransaction

    def update_user_balance
      user.decrement(:loyalty_points_balance, loyalty_points)
      user.save!
    end

    def update_balance
      self.balance = user.loyalty_points_balance - loyalty_points
    end

  end
end