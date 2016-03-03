Spree.user_class.class_eval do
  validates :loyalty_points_balance, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  has_many :loyalty_points_transactions, foreign_key: :user_id
  has_many :loyalty_points_debit_transactions, foreign_key: :user_id
  has_many :loyalty_points_credit_transactions, foreign_key: :user_id

  def loyalty_points_balance_sufficient?
    loyalty_points_balance >= Spree::Config.loyalty_points_redeeming_balance
  end

  def has_sufficient_loyalty_points?(order)
    loyalty_points_equivalent_currency >= order.total
  end

  def loyalty_points_equivalent_currency
    loyalty_points_balance * Spree::Config.loyalty_points_conversion_rate
  end

end
