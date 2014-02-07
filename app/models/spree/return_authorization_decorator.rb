#TODO -> Show all information related to transactions either debit or credit in creating return authorization at admin end. Also, confirm in which condition admin would debit and credit with return.

Spree::ReturnAuthorization.class_eval do

  def update_loyalty_points
    if loyalty_points_transaction_type == "Debit"
      loyalty_points_debit_quantity = [order.user.loyalty_points_balance, order.loyalty_points_for(order.item_total), loyalty_points].min
      order.create_debit_transaction(loyalty_points_debit_quantity)
    else
      loyalty_points_credit_quantity = [order.loyalty_points_for(order.total), loyalty_points].min
      order.create_credit_transaction(loyalty_points_credit_quantity)
    end
  end

end

Spree::ReturnAuthorization.state_machine.after_transition :to => :received, :do => :update_loyalty_points
