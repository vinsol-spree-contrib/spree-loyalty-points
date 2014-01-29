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

  def order_transactions
    order = Spree::Order.find_by(id: params[:order_id])
    @loyalty_points = @user.loyalty_points_transactions.for_order(order).includes(:source).order('updated_at DESC')
    respond_to do |format|
      format.json do
        render json: @loyalty_points.to_json(
          :include => {
            :source => {
              :only => [:id, :number]
            }
          },
          :only => [:transaction_type, :source_type, :comment, :updated_at, :loyalty_points, :updated_balance]
        )
      end
    end
  end

  private

    def set_user
      unless @user = Spree::User.find_by(id: params[:user_id])
        redirect_to admin_users_path, notice: 'User not found'
      end
    end

    def loyalty_points_transaction_params
      params.require(:loyalty_points_transaction).permit(:loyalty_points, :transaction_type, :comment, :source_id, :source_type)
    end

end
