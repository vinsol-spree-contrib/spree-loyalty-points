module Spree
  CheckoutController.class_eval do
    before_filter :sufficient_loyalty_points, only: [:update], if: -> { params[:state] == 'payment' }

    def update
      if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
        @order.temporary_address = !params[:save_user_address]
        unless @order.next
          flash[:error] = @order.errors.full_messages.join("\n")
          redirect_to(checkout_state_path(@order.state)) && return
        end

        if @order.completed?
          @current_order = nil
          flash.notice = Spree.t(:order_processed_successfully)
          flash['order_completed'] = true
          redirect_to completion_route
        else
          redirect_to checkout_state_path(@order.state)
        end
      else
        render :edit
      end
    end

    private

      def sufficient_loyalty_points
        payment_method_ids = params[:order][:payments_attributes].collect do |payment|
          payment["payment_method_id"]
        end
        if Spree::PaymentMethod.loyalty_points_id_included?(payment_method_ids) && !@order.user.has_sufficient_loyalty_points?(@order)
          flash[:error] = Spree.t(:insufficient_loyalty_points)
          redirect_to checkout_state_path(@order.state)
        end
      end
  end
end
