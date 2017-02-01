module Spree
  CheckoutController.class_eval do
    before_action :sufficient_loyalty_points, only: [:update], if: -> { params[:state] == 'payment' }

    private

      def sufficient_loyalty_points
        payment_method_ids = params[:order][:payments_attributes].collect do |payment|
          payment["payment_method_id"]
        end
        if Spree::PaymentMethod.loyalty_points_id_included?(payment_method_ids) && !@order.user.has_sufficient_loyalty_points?(@order)
          flash[:error] = Spree.t(:insufficient_loyalty_points)
          redirect_to spree.checkout_state_path(@order.state)
        end
      end
  end
end
