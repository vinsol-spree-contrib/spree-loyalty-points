class AddTransactionIdToSpreeLoyaltyPointsTransactions < ActiveRecord::Migration
  def change
    add_column :spree_loyalty_points_transactions, :transaction_id, :string
  end
end
