#TODO -> Show all information related to transactions either debit or credit in creating return authorization at admin end. Also, confirm in which condition admin would debit and credit with return.

Spree::ReturnAuthorization.class_eval do

  validate :negative_loyalty_points_total, if: -> { order.loyalty_points_used? && order.loyalty_points_debit_transactions.present? }
  validate :positive_loyalty_points_total, if: -> { !order.loyalty_points_used? && order.loyalty_points_credit_transactions.present? }

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

    def negative_loyalty_points_total
      positive_total = order.loyalty_points_credit_transactions.sum(:loyalty_points) + loyalty_points
      negative_total = order.loyalty_points_debit_transactions.sum(:loyalty_points)
      if negative_total < positive_total
        errors.add :base, 'Loyalty Points Total cannot be positive for this order'
      end
    end

    def positive_loyalty_points_total
      positive_total = order.loyalty_points_credit_transactions.sum(:loyalty_points)
      negative_total = order.loyalty_points_debit_transactions.sum(:loyalty_points) + loyalty_points
      if negative_total > positive_total
        errors.add :base, 'Loyalty Points Total cannot be negative for this order'
      end
    end

end

Spree::ReturnAuthorization.state_machine.after_transition :to => :received, :do => :update_loyalty_points
