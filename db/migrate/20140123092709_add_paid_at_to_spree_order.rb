class AddPaidAtToSpreeOrder < ActiveRecord::Migration
  def change
    add_column :spree_orders, :paid_at, :datetime
  end
end
