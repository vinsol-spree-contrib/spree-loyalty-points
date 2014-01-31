Spree::ReturnAuthorization.class_eval do

  TRANSACTIONS_TYPE = { "Credit" => "Spree::LoyaltyPointsCreditTransaction", "Debit" => "Spree::LoyaltyPointsDebitTransaction"}

  def update_loyalty_points
    order.update_loyalty_points(loyalty_points, loyalty_points_transaction_class)
  end

  def loyalty_points_transaction_class
    TRANSACTIONS_TYPE[loyalty_points_transaction_type]
  end

end

Spree::ReturnAuthorization.state_machine.after_transition :to => :received, :do => :update_loyalty_points
