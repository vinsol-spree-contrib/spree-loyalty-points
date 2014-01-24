Spree::AppConfiguration.class_eval do
  preference :loyalty_points_unit_amount, :decimal
  preference :loyalty_points_awarding_unit, :integer, :default => 0
  preference :loyalty_points_redeeming_balance, :decimal
  preference :loyalty_points_conversion_rate, :decimal, :default => 0.0
  preference :loyalty_points_award_period, :integer, :default => 1
end
