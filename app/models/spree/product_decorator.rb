Spree::Product.class_eval do
  scope :loyalty_points_eligible, -> { where(loyalty_points_eligible: true) }
end
