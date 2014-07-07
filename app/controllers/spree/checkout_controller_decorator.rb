module Spree
  CheckoutController.class_eval do
    before_filter :sufficient_loyalty_points, only: [:update], if: -> { params[:state] == 'payment' }

    private

      def sufficient_loyalty_points
        payment_method_ids = params[:order][:payments_attributes].collect do |v1, v2|
          #params[:order][:payments_attributes] can be a hash or array. E.g. 
          # params[:order][:payments_attributes] = { 
          #   “0” => {“payment_method_id” => 8, “amount” => 100}, 
          #   “1” => {“payment_method_id” => 9, “amount” => 50} 
          # }
          # params[:order][:payments_attributes] = [
          #   {“payment_method_id” => 8, “amount” => 100},
          #   {“payment_method_id” => 9, “amount” => 50}
          # ]
          payment = v2 || v1
          payment["payment_method_id"]
        end
        if Spree::PaymentMethod.loyalty_points_id_included?(payment_method_ids) && !@order.user.has_sufficient_loyalty_points?(@order)
          flash[:error] = Spree.t(:insufficient_loyalty_points)
          redirect_to checkout_state_path(@order.state)
        end
      end
  end
end
