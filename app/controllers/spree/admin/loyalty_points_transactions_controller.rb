class Spree::Admin::LoyaltyPointsTransactionsController < Spree::Admin::ResourceController
  before_action :set_user, only: [:order_transactions]
  belongs_to 'spree/user'
  before_action :set_ordered_transactions, only: [:index]

  def order_transactions
    order = Spree::Order.find_by(id: params[:order_id])
    @loyalty_points_transactions = @user.loyalty_points_transactions.for_order(order).includes(:source).order(updated_at: :desc)
    respond_to do |format|
      format.json do
        render json: @loyalty_points_transactions.to_json(
          :include => {
            :source => {
              :only => [:id, :number]
            }
          },
          :only => [:source_type, :comment, :updated_at, :loyalty_points, :balance],
          :methods => [:transaction_type]
        )
      end
    end
  end

  def create
    invoke_callbacks(:create, :before)
    @object.attributes = loyalty_points_transaction_params
    if @object.save
      invoke_callbacks(:create, :after)
      flash[:success] = flash_message_for(@object, :successfully_created)
      respond_with(@object) do |format|
        format.html { redirect_to location_after_save }
        format.js   { render :layout => false }
      end
    else
      invoke_callbacks(:create, :fails)
      respond_with(@object) do |format|
        format.html { render action: :new }
      end
    end
  end

  protected

    def set_user
      unless @user = Spree::User.find_by(id: params[:user_id])
        redirect_to admin_users_path, notice: 'User not found'
      end
    end

    def loyalty_points_transaction_params
      params.require(:loyalty_points_transaction).permit(:loyalty_points, :type, :comment, :source_id, :source_type)
    end

    def build_resource
      if params[:loyalty_points_transaction].present? && params[:loyalty_points_transaction][:type].present?
        parent.send(association_name(params[:loyalty_points_transaction][:type])).build
      else
        parent.send(controller_name).build
      end
    end

    def association_name(klass)
      klass.gsub('Spree::', '').pluralize.underscore
    end

    def collection_url
      if (parent_data.present? && @parent.nil?) || parent_data.blank?
        admin_users_url
      else
        admin_user_loyalty_points_transactions_url(@parent)
      end
    end

    def set_ordered_transactions
      @loyalty_points_transactions = @loyalty_points_transactions.order(updated_at: :desc).
        page(params[:page]).
        per(params[:per_page] || Spree::Config[:orders_per_page])
    end

end
