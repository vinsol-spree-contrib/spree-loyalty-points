class Spree::Admin::LoyaltyPointsController < Spree::Admin::BaseController
  before_action :set_user

  def index
    @loyalty_points = @user.loyalty_points_transactions.includes(:source).order('updated_at DESC').
      page(params[:page]).
      per(params[:per_page] || Spree::Config[:orders_per_page])
  end

  def new
    @loyalty_points_transaction = @user.loyalty_points_transactions.build
  end

  def create
    @loyalty_points_transaction = @user.loyalty_points_transactions.create(loyalty_points_transaction_params)
    if @loyalty_points_transaction.persisted?
      redirect_to admin_users_path, notice: "Successfully #{ loyalty_points_transaction_params[:transaction_type] }ed user's Loyalty Points"
    else
      render action: :new
    end
  end

  private

    def set_user
      unless @user = Spree::User.find_by(id: params[:user_id])
        redirect_to admin_root_path, notice: 'User not found'
      end
    end

    def loyalty_points_transaction_params
      params.require(:loyalty_points_transaction).permit(:loyalty_points, :transaction_type, :comment, :source_id, :source_type)
    end

end
