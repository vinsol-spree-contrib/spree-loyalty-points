class AddLoyaltyPointsToSpreeReturnAuthorization < ActiveRecord::Migration
  def change
    add_column :spree_return_authorizations, :loyalty_points, :integer, default: 0, null: false
    add_column :spree_return_authorizations, :loyalty_points_transaction_type, :string
  end
end
