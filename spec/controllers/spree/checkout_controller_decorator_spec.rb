require 'spec_helper'

describe Spree::CheckoutController do

  let(:loyalty_points_payment_method) { Spree::PaymentMethod::LoyaltyPoints.create!(:environment => Rails.env, :active => true, :name => 'Loyalty_Points') }
  let(:payment) { Spree::Payment.new(:amount => 50.0) }

  before(:each) do
    @user = create(:user_with_loyalty_points)
    controller.stub(:spree_current_user).and_return(@user)
    @user.stub(:generate_spree_api_key!).and_return(true)
    controller.stub(:authorize!).and_return(true)
    @order = create(:order_with_loyalty_points)
    @order.stub(:user).and_return(@user)
  end

  describe "PUT 'update'" do

    before :each do
      controller.stub(:ensure_order_not_completed).and_return(true)
      controller.stub(:ensure_checkout_allowed).and_return(true)
      controller.stub(:ensure_sufficient_stock_lines).and_return(true)
      controller.stub(:ensure_valid_state).and_return(true)
      controller.stub(:associate_user).and_return(true)
      controller.stub(:check_authorization).and_return(true)
      controller.stub(:current_order).and_return(@order)  
      controller.stub(:setup_for_current_state).and_return(true)
      controller.stub(:spree_current_user).and_return(@user)
      @order.stub(:payment?).and_return(true)
      controller.stub(:after_update_attributes).and_return(false)
    end

    context "when loyalty points used" do

      before :each do
        controller.stub(:loyalty_points_used?).and_return(true)
        @user.stub(:has_sufficient_loyalty_points?).and_return(false)
      end
  
      it "should redirect to payments page" do
        put :update, state: "payment", order: { payments_attributes: [{:payment_method_id => loyalty_points_payment_method.id}] }, use_route: :spree
        expect(response).to redirect_to(checkout_state_path(@order.state))
      end

    end

  end

  describe "loyalty_points_used?" do

    let(:payments) { create_list(:payment_with_loyalty_points, 3) }

    context "when loyalty points are used" do

      before :each do
        payments.each do |payment|
          payment.payment_method = loyalty_points_payment_method
          payment.save!
        end
      end

      it "should return true" do
        controller.send(:loyalty_points_used?, payments).should eq(true)
      end
      
    end

  end

end
