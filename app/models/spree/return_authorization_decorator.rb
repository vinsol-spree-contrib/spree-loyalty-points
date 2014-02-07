#TODO -> Show all information related to transactions either debit or credit in creating return authorization at admin end. Also, confirm in which condition admin would debit and credit with return.

Spree::ReturnAuthorization.class_eval do

  def update_loyalty_points
    order.update_loyalty_points(loyalty_points, loyalty_points_transaction_type)
  end

end

Spree::ReturnAuthorization.state_machine.after_transition :to => :received, :do => :update_loyalty_points
