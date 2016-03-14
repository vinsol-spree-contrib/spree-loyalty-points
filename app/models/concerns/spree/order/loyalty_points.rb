require 'active_support/concern'

module Spree
  class Order
    module LoyaltyPoints
      extend ActiveSupport::Concern

      def loyalty_points_total
        loyalty_points_credit_transactions.sum(:loyalty_points) - loyalty_points_debit_transactions.sum(:loyalty_points)
      end

      def award_loyalty_points
        loyalty_points_earned = loyalty_points_for(item_total)
        if !loyalty_points_used?
          create_credit_transaction(loyalty_points_earned)
        end
      end

      def loyalty_points_awarded?
        loyalty_points_credit_transactions.count > 0
      end

      def loyalty_points_used?
        payments.any_with_loyalty_points?
      end

      module ClassMethods

        def credit_loyalty_points_to_user
          points_award_period = Spree::Config.loyalty_points_award_period
          uncredited_orders = Spree::Order.with_uncredited_loyalty_points(points_award_period)
          uncredited_orders.each do |order|
            order.award_loyalty_points
          end
        end

      end

      def create_credit_transaction(points)
        user.loyalty_points_credit_transactions.create(source: self, loyalty_points: points)
      end

      def create_debit_transaction(points)
        user.loyalty_points_debit_transactions.create(source: self, loyalty_points: points)
      end

      private

        def complete_loyalty_points_payments
          payments.by_loyalty_points.with_state('checkout').each { |payment| payment.complete! }
        end

    end
  end
end