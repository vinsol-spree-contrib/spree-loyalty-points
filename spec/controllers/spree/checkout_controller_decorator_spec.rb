require 'spec_helper'

describe Spree::CheckoutController, type: :controller do

  let(:user) { mock_model(Spree.user_class).as_null_object }
  let(:order) { mock_model(Spree::Order).as_null_object }
  let(:loyalty_points_payment_method) { Spree::PaymentMethod::LoyaltyPoints.create!(active: true, name: 'Loyalty_Points') }
  let(:payment) { Spree::Payment.new(amount: 50.0) }

  before(:each) do
    controller.stub(:spree_current_user).and_return(user)
    user.stub(:generate_spree_api_key!).and_return(true)
    controller.stub(:authorize!).and_return(true)
    controller.stub(:load_order).and_return(true)
  end

  describe "PUT 'update'" do
    before :each do
      controller.stub(:ensure_order_not_completed).and_return(true)
      controller.stub(:ensure_sufficient_stock_lines).and_return(true)
      controller.instance_variable_set(:@order, order)
      controller.stub(:load_order_with_lock).and_return(true)
    end

    context "when state is payment" do

      def send_request
        put :update, state: "payment", order: { payments_attributes: [{payment_method_id: loyalty_points_payment_method.id}], id: order.id }
      end

      context "when loyalty points used" do

        before :each do
          Spree::PaymentMethod.stub(:loyalty_points_id_included?).and_return(true)
          order.user.stub(:has_sufficient_loyalty_points?).and_return(true)
          order.stub(:can_go_to_state?).and_return(false)
        end

        it "should receive loyalty_points_id_included? on Spree::PaymentMethod" do
          Spree::PaymentMethod.should_receive(:loyalty_points_id_included?)
          send_request
        end

        it "should receive has_sufficient_loyalty_points? on Spree::PaymentMethod" do
          order.user.should_receive(:has_sufficient_loyalty_points?)
          send_request
        end

        context "when user does not have sufficient loyalty points" do

          before :each do
            Spree::PaymentMethod.stub(:loyalty_points_id_included?).and_return(true)
            order.user.stub(:has_sufficient_loyalty_points?).and_return(false)
          end

          it "should add error to flash" do
            send_request
            flash[:error].should eq(Spree.t(:insufficient_loyalty_points))
          end

          it "should redirect to payments page" do
            send_request
            expect(response).to redirect_to(checkout_state_path(order.state))
          end

        end

        context "when user has sufficient loyalty points" do

          before :each do
            order.user.stub(:has_sufficient_loyalty_points?).and_return(true)
            order.stub(:completed?).and_return(false)
          end

          it "should not add error to flash" do
            send_request
            flash[:error].should be_nil
          end

          it "should redirect to payments page" do
            send_request
            expect(response).to redirect_to(checkout_state_path(order.state))
          end

        end

      end

      context "when loyalty points not used" do

        let(:check_payment_method) { Spree::PaymentMethod::Check.create!(active: true, name: 'Check') }

        def send_request
          put :update, state: "payment", order: { payments_attributes: [{payment_method_id: check_payment_method.id}], id: order.id }
        end

        before :each do
          Spree::PaymentMethod.stub(:loyalty_points_id_included?).and_return(false)
          order.stub(:can_go_to_state?).and_return(false)
        end

        it "should receive loyalty_points_id_included? on Spree::PaymentMethod" do
          Spree::PaymentMethod.should_receive(:loyalty_points_id_included?)
          send_request
        end

      end

    end

  end

end
