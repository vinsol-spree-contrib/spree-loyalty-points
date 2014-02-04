#TODO -> Use concern for loyaltypoint related logic in order model.

Spree::Order.class_eval do
  has_many :loyalty_points_transactions, as: :source
  has_many :loyalty_points_credit_transactions, as: :source
  has_many :loyalty_points_debit_transactions, as: :source

  scope :loyalty_points_not_awarded, -> { includes(:loyalty_points_credit_transactions).where(:spree_loyalty_points_transactions => { :source_id => nil } ) }

  def add_loyalty_points
    loyalty_points_earned = loyalty_points_for(item_total)
    if !payment_by_loyalty_points?
      new_loyalty_points_credit_transaction(loyalty_points_earned)
    end
  end

  def redeem_loyalty_points
    loyalty_points_redeemed = loyalty_points_for(total, 'redeem')
    if payment_by_loyalty_points? && redeemable_loyalty_points_balance?(total)
      new_loyalty_points_transaction(loyalty_points_redeemed, 'Spree::LoyaltyPointsDebitTransaction')
    end
  end

  #TODO -> Please confirm whether we use item_total or total as it is used for redeeming awarded loyalty points after receiving return_authorization.
  def update_loyalty_points(quantity, trans_type)
    loyalty_points_debit_quantity = [user.loyalty_points_balance, loyalty_points_for(total), quantity].min
    if trans_type == "Debit"
      new_loyalty_points_debit_transaction(loyalty_points_debit_quantity)
    else
      new_loyalty_points_credit_transaction(loyalty_points_debit_quantity)
    end
  end

  # TODO -> Create loyalty points transactions by using LoyaltyPointsDebitTransaction or LoyaltyPointsCreditTransaction instead of passing type as argument.
  def new_loyalty_points_credit_transaction(quantity)
    if quantity != 0
      user.loyalty_points_credit_transactions.create(source: self, loyalty_points: quantity)
    end
  end

  def new_loyalty_points_debit_transaction(quantity)
    if quantity != 0
      user.loyalty_points_debit_transactions.create(source: self, loyalty_points: quantity)
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

  def loyalty_points_awarded?
    loyalty_points_credit_transactions.count > 0
  end

end

#TODO -> Redeem loyalty points before completing the order. Also, we can move this logic in before completing the correponding loyalty_point payment 

Spree::Order.state_machine.after_transition :to => :complete, :do => :redeem_loyalty_points
