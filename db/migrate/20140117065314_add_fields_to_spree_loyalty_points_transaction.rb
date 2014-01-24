class AddFieldsToSpreeLoyaltyPointsTransaction < ActiveRecord::Migration
  def change
    add_column :spree_loyalty_points_transactions, :source_type, :string
    rename_column :spree_loyalty_points_transactions, :order_id, :source_id
    add_column :spree_loyalty_points_transactions, :updated_balance, :integer, default: 0, null: false
  end
end
