class AddCommentToSpreeLoyaltyPointsTransaction < ActiveRecord::Migration
  def change
    add_column :spree_loyalty_points_transactions, :comment, :string
  end
end
