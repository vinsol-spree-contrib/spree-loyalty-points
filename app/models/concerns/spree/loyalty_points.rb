#TODO -> Write rspecs by using shared_example and then call that shared_example in respective classes.
require 'active_support/concern'

module Spree
  module LoyaltyPoints
    extend ActiveSupport::Concern

    def loyalty_points_for(amount, purpose = 'award')
      loyalty_points = if purpose == 'award' && eligible_for_loyalty_points?(amount)
        (amount * Spree::Config.loyalty_points_awarding_unit).floor
      elsif purpose == 'redeem'
        (amount / Spree::Config.loyalty_points_conversion_rate).ceil
      else
        0
      end
    end

    #TODO -> Rspecs missed for this method.
    def eligible_for_loyalty_points?(amount)
      amount >= Spree::Config.min_amount_required_to_get_loyalty_points
    end

  end
end