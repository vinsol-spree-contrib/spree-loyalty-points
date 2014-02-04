module Spree
  CheckoutController.class_eval do
    before_filter :sufficient_loyalty_points, only: [:update], if: -> { params[:state] == 'payment' }

    private

      def sufficient_loyalty_points
        payments = params[:order][:payments_attributes].collect do |payment|
          Spree::Payment.new(payment)
        end
        if loyalty_points_used?(payments) && !@order.user.has_sufficient_loyalty_points?(@order)
          flash[:error] = Spree.t(:insufficient_loyalty_points)
          redirect_to checkout_state_path(@order.state)
        end
      end

      #TODO -> This can be moved to model. Infact payment_by_loyalty_points? method can be used which is currently present in order model.
      def loyalty_points_used?(payments)
        payments.any? { |payment| payment.payment_method.type == "Spree::PaymentMethod::LoyaltyPoints" && payment.state != "invalid" }
      end

  end
end
