module Spree
  class LoyaltyPointsController < StoreController

    def index
      if spree_current_user.present?
        @loyalty_points_transactions = spree_current_user.loyalty_points_transactions.includes(:source).order(updated_at: :desc).
                                        page(params[:page]).
                                        per(params[:per_page] || Spree::Config[:orders_per_page])
      else
        @loyalty_points_transactions = []
      end
    end

  end
end
