Spree::LineItem.class_eval do
  delegate :loyalty_points_eligible, to: :product
end
