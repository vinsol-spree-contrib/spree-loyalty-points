module Spree
  class LoyaltyPointsController < StoreController

    def index
      @loyalty_points_transactions = spree_current_user.loyalty_points_transactions.includes(:source).order(updated_at: :desc).
                                       page(params[:page]).
                                       per(params[:per_page] || Spree::Config[:orders_per_page])
    end

  end
end
