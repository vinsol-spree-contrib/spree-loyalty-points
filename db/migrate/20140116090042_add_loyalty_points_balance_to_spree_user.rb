class AddLoyaltyPointsBalanceToSpreeUser < ActiveRecord::Migration
  def change
    add_column :spree_users, :loyalty_points_balance, :integer
  end
end
