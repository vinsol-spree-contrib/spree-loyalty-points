class AddIndexingToSpreeLoyaltyPointsTransaction < ActiveRecord::Migration
  def change
    add_index :spree_loyalty_points_transactions, [:source_type, :source_id], name: 'by_source'
    add_index :spree_loyalty_points_transactions, :user_id
    add_index :spree_loyalty_points_transactions, :type
  end
end
