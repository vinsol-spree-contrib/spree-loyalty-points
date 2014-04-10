require 'active_support/concern'

module Spree
  module LoyaltyPoints
    extend ActiveSupport::Concern

    class IntegerPointFormat
      def display object, points
        points.to_s
      end
    end

    @@loyalty_points_format = IntegerPointFormat.new
    mattr_accessor :loyalty_points_format

    def loyalty_points_display(amount)
      @@loyalty_points_format.display self, amount
    end

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

  end
end
