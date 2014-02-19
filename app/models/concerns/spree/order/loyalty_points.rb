require 'active_support/concern'

module Spree
  class Order < ActiveRecord::Base
    module LoyaltyPoints
      extend ActiveSupport::Concern

      #TODO -> Change name of this method.
      def award_loyalty_points
        loyalty_points_earned = loyalty_points_for(item_total)
        if !loyalty_points_used?
          create_credit_transaction(loyalty_points_earned)
        end
      end

      def redeem_loyalty_points(amount = nil)
        loyalty_points_redeemed = loyalty_points_for(total, 'redeem')
        loyalty_points_redeemed = loyalty_points_for(amount) if amount
        if loyalty_points_used? && redeemable_loyalty_points_balance?(total)
          create_debit_transaction(loyalty_points_redeemed)
        end
      end

      def return_loyalty_points(amount = nil)
        loyalty_points_redeemed = loyalty_points_for(total, 'redeem')
        loyalty_points_redeemed = loyalty_points_for(amount) if amount
        create_credit_transaction(loyalty_points_redeemed)
      end

      #TODO -> Please confirm whether we use item_total or total as it is used for redeeming awarded loyalty points after receiving return_authorization.
        #TODO -> We can create new

      def loyalty_points_for(amount, purpose = 'award')
        loyalty_points = if purpose == 'award' && eligible_for_loyalty_points?(amount)
          (amount * Spree::Config.loyalty_points_awarding_unit).floor
        elsif purpose == 'redeem'
          (amount / Spree::Config.loyalty_points_conversion_rate).ceil
        else
          0
        end
      end

      def eligible_for_loyalty_points?(amount)
        amount >= Spree::Config.min_amount_required_to_get_loyalty_points
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
          #TODO -> create scope in order model.
          uncredited_orders = Spree::Order.with_uncredited_loyalty_points(points_award_period)
          uncredited_orders.each do |order|
            order.award_loyalty_points
          end
        end

      end
      
      #TODO -> change name of this method to something like credit_loyalty_points.
      def create_credit_transaction(points)
        user.loyalty_points_credit_transactions.create(source: self, loyalty_points: points)
      end

      #TODO -> change name of this method.
      def create_debit_transaction(points)
        user.loyalty_points_debit_transactions.create(source: self, loyalty_points: points)
      end

      private

        def complete_loyalty_points_payments
          payments.by_loyalty_points.with_state('checkout').each { |payment| payment.complete! }
        end

        def redeemable_loyalty_points_balance?(amount)
          amount >= Spree::Config.loyalty_points_redeeming_balance
        end
    end
  end
end