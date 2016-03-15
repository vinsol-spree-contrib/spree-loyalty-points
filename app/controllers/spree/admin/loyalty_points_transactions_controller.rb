module Spree
  module Admin
    class LoyaltyPointsTransactionsController < ResourceController
      belongs_to Spree.user_class.to_s.underscore
      before_action :set_user, only: :order_transactions
      before_action :set_ordered_transactions, only: :index

      def order_transactions
        order = Spree::Order.find_by(id: params[:order_id])
        @loyalty_points_transactions = @user.loyalty_points_transactions.for_order(order).includes(:source).order(updated_at: :desc)
        respond_with @loyalty_points_transactions
      end

      def create
        invoke_callbacks(:create, :before)
        @object.attributes = loyalty_points_transaction_params
        if @object.save
          invoke_callbacks(:create, :after)
          respond_with(@object) do |format|
            format.html { redirect_to location_after_save, success: flash_message_for(@object, :successfully_created) }
            format.js   { render layout: false }
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
          unless @user = Spree.user_class.find_by(id: params[:user_id])
            redirect_to spree.admin_users_path, notice: flash_message_for(Spree.user_class.new, :not_found)
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
            spree.admin_users_url
          else
            spree.admin_user_loyalty_points_url(parent)
          end
        end

        def set_ordered_transactions
          @loyalty_points_transactions = @loyalty_points_transactions.order(updated_at: :desc).
            page(params[:page]).
            per(params[:per_page] || Spree::Config[:orders_per_page])
        end
    end
  end
end
