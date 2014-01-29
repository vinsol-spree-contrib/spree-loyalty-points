Spree::Order.class_eval do
  has_many :loyalty_points_transactions, as: :source

  def add_loyalty_points
    loyalty_points_earned = loyalty_points_for(item_total)
    if !payment_by_loyalty_points?
      new_loyalty_points_transaction(loyalty_points_earned, 'Credit')
    end
  end

  def redeem_loyalty_points
    loyalty_points_redeemed = loyalty_points_for(total, 'redeem')
    if payment_by_loyalty_points? && redeemable_loyalty_points_balance?(total)
      new_loyalty_points_transaction(loyalty_points_redeemed, 'Debit')
    end
  end

  def update_loyalty_points(quantity, trans_type)
    loyalty_points_debit_quantity = [user.loyalty_points_balance, loyalty_points_for(total), quantity].min
    new_loyalty_points_transaction(loyalty_points_debit_quantity, trans_type)
  end

  def new_loyalty_points_transaction(quantity, trans_type)
    if quantity != 0
      user.loyalty_points_transactions.create(source: self, loyalty_points: quantity, transaction_type: trans_type)
    end
  end

  def loyalty_points_for(amount, purpose = 'award')
    loyalty_points = if purpose == 'award' && eligible_for_loyalty_points?(amount)
      (amount * Spree::Config.loyalty_points_awarding_unit).floor
    elsif purpose == 'redeem'
      (amount / Spree::Config.loyalty_points_conversion_rate).ceil
    else
      0
    end
  end

  def payment_by_loyalty_points?
    payments.includes(:payment_method).any? { |payment| payment.payment_method.type == "Spree::PaymentMethod::LoyaltyPoints" && payment.state != "invalid" }
  end

  def eligible_for_loyalty_points?(amount)
    amount >= Spree::Config.min_amount_required_to_get_loyalty_points
  end

  def redeemable_loyalty_points_balance?(amount)
    amount >= Spree::Config.loyalty_points_redeeming_balance
  end

  def mark_awarded
    update_column(:loyalty_points_awarded, true)
  end

end

Spree::Order.state_machine.after_transition :to => :complete, :do => :redeem_loyalty_points
