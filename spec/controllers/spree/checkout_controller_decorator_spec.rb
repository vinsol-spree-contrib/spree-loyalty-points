require 'spec_helper'

describe Spree::CheckoutController do

  let(:user) { mock_model(Spree::User).as_null_object }
  let(:order) { mock_model(Spree::Order).as_null_object }
  let(:loyalty_points_payment_method) { Spree::PaymentMethod::LoyaltyPoints.create!(:environment => Rails.env, :active => true, :name => 'Loyalty_Points') }
  let(:payment) { Spree::Payment.new(:amount => 50.0) }

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
        put :update, state: "payment", order: { payments_attributes: [{:payment_method_id => loyalty_points_payment_method.id}], id: order.id }, use_route: :spree
      end

      it "should receive sufficient_loyalty_points on Spree::PaymentMethod" do
        controller.should_receive(:sufficient_loyalty_points)
        send_request
      end

      context "when loyalty points used" do

        before :each do
          Spree::PaymentMethod.stub(:loyalty_points_id_included?).with(["#{loyalty_points_payment_method.id}"]).and_return(true)
        end

        #TODO: Need to fix these specs
        it "should receive loyalty_points_id_included? on Spree::PaymentMethod" do
          Spree::PaymentMethod.should_receive(:loyalty_points_id_included?).with(["#{loyalty_points_payment_method.id}"])
          send_request
        end

        it "should receive has_sufficient_loyalty_points? on Spree::PaymentMethod" do
          order.user.should_receive(:has_sufficient_loyalty_points?).with(order)
          send_request
        end

        context "when user does not have sufficient loyalty points" do

          before :each do
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
          end

          it "should not add error to flash" do
            send_request
            flash[:error].should be_nil
          end

          it "should redirect to payments page" do
            send_request
            expect(response).not_to redirect_to(checkout_state_path(order.state))
          end

        end

      end

      context "when loyalty points not used" do

        let(:check_payment_method) { Spree::PaymentMethod::Check.create!(:environment => Rails.env, :active => true, :name => 'Check') }

        def send_request
          put :update, state: "payment", order: { payments_attributes: [{:payment_method_id => check_payment_method.id}], id: order.id }, use_route: :spree
        end

        before :each do
          Spree::PaymentMethod.stub(:loyalty_points_id_included?).with(["#{check_payment_method.id}"]).and_return(false)
        end

        it "should receive loyalty_points_id_included? on Spree::PaymentMethod" do
          Spree::PaymentMethod.should_receive(:loyalty_points_id_included?).with(["#{check_payment_method.id}"])
          send_request
        end

        it "should not receive has_sufficient_loyalty_points? on Spree::PaymentMethod" do
          order.user.should_not_receive(:has_sufficient_loyalty_points?).with(order)
          send_request
        end

      end

    end

    context "when state is not payment" do

      def send_request
        put :update, state: "delivery", order: { payments_attributes: [{:payment_method_id => loyalty_points_payment_method.id}], id: order.id }, use_route: :spree
      end

      it "should not receive sufficient_loyalty_points on Spree::PaymentMethod" do
        controller.should_not_receive(:sufficient_loyalty_points)
        send_request
      end

    end

  end

end
