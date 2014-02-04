#TODO -> Mark loyalty point payment completed automatically.
module Spree
  class PaymentMethod::LoyaltyPoints < PaymentMethod
    def actions
      %w{capture void}
    end

    def can_void?(payment)
      payment.state != 'void'
    end

    def can_capture?(payment)
      ['checkout', 'pending'].include?(payment.state)
    end

    def capture(payment, source, gateway)
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    #TODO -> Credit loyalty points not just in payment void. Instead in any transition from complete state to any other state.
    def void(source, gateway)
      order = get_order(gateway[:order_id])
      user = order.user
      loyalty_points_redeemed = order.loyalty_points_for(order.total, 'redeem')

      user.loyalty_points_transactions.create(source: order, loyalty_points: loyalty_points_redeemed, type: 'Spree::LoyaltyPointsCreditTransaction')
      ActiveMerchant::Billing::Response.new(true, "", {}, {})
    end

    def source_required?
      false
    end

    private

      def get_order(order_id)
        actual_order_id = order_id.split('-').first
        Spree::Order.find_by_number(actual_order_id)
      end

  end
end
