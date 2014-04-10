class AddLoyaltyPointsEligibleFlagToSpreeProduct < ActiveRecord::Migration
  def change
    add_column :spree_products, :loyalty_points_eligible, :boolean, default: true, null: false
  end
end
