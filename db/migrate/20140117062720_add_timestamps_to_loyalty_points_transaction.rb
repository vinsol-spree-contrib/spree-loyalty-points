class AddTimestampsToLoyaltyPointsTransaction < ActiveRecord::Migration
  def change
    change_table :spree_loyalty_points_transactions do |t|
      t.timestamps
    end
  end
end
