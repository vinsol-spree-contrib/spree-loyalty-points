Spree::ReturnAuthorization.class_eval do
  include Spree::TransactionsTotalValidation
  validate :transactions_total_range, if: -> { order.present? && order.loyalty_points_transactions.present? }

  def update_loyalty_points
    if loyalty_points_transaction_type == "Debit"
      loyalty_points_debit_quantity = [order.user.loyalty_points_balance, order.loyalty_points_for(order.item_total), loyalty_points].min
      order.create_debit_transaction(loyalty_points_debit_quantity)
    else
      loyalty_points_credit_quantity = [order.loyalty_points_for(order.total), loyalty_points].min
      order.create_credit_transaction(loyalty_points_credit_quantity)
    end
  end

  private

    def transactions_total_range
      validate_transactions_total_range(loyalty_points_transaction_type, order)
    end

end

Spree::ReturnAuthorization.state_machine.after_transition :to => :received, :do => :update_loyalty_points
