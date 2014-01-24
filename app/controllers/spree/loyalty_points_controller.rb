class Spree::LoyaltyPointsController < Spree::StoreController

  def index
    @loyalty_points = spree_current_user.loyalty_points_transactions.includes(:source).order('updated_at DESC').
      page(params[:page]).
      per(params[:per_page] || Spree::Config[:orders_per_page])
  end

end
