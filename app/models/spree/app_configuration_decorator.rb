#TODO -> Rspecs for this model.
Spree::AppConfiguration.class_eval do
  preference :min_amount_required_to_get_loyalty_points, :decimal, :default => 20.0
  preference :loyalty_points_awarding_unit, :decimal, :default => 0.0
  preference :loyalty_points_redeeming_balance, :integer, :default => 50
  preference :loyalty_points_conversion_rate, :decimal, :default => 5.0
  preference :loyalty_points_award_period, :integer, :default => 1
end
