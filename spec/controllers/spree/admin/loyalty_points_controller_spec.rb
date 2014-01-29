require 'spec_helper'

describe Spree::Admin::LoyaltyPointsController do

  context "when user found" do
    
    before(:each) do
      user = create(:user_with_loyalty_points)
      controller.stub(:spree_current_user).and_return(user)
      user.stub(:generate_spree_api_key!).and_return(true)
      controller.stub(:authorize!).and_return(true)
      controller.stub(:authorize_admin).and_return(true)
      Spree::User.stub(:find_by).and_return(user)
      @loyalty_points_transaction = create(:loyalty_points_transaction)
      user.loyalty_points_transactions.stub(:create).and_return(@loyalty_points_transaction)
    end

    describe "GET 'index'" do

      it "assigns @loyalty_points" do
        get :index, :use_route => :spree
        assigns[:loyalty_points].should_not be_nil
      end

      it "renders index template" do
        get :index, :use_route => :spree
        expect(response).to render_template(:index)
      end

    end

    describe "GET 'new'" do

      it "assigns @loyalty_points_transaction" do
        get :new, :use_route => :spree
        assigns[:loyalty_points_transaction].should_not be_nil
      end

      it "renders new template" do
        get :new, :use_route => :spree
        expect(response).to render_template(:new)
      end

    end

    describe "POST 'create'" do

      it "assigns @loyalty_points_transaction" do
        post :create, loyalty_points_transaction: attributes_for(:loyalty_points_transaction), :use_route => :spree
        assigns[:loyalty_points_transaction].should_not be_nil
      end

      context "when transaction created " do

        it "redirects to admin users page" do
          post :create, loyalty_points_transaction: attributes_for(:loyalty_points_transaction), :use_route => :spree
          expect(response).to redirect_to(admin_users_path)
        end

      end

      context "when transaction failed " do

        before :each do
          @loyalty_points_transaction.stub(:persisted?).and_return(false)
        end

        it "renders new template" do
          post :create, loyalty_points_transaction: attributes_for(:loyalty_points_transaction), :use_route => :spree
          expect(response).to render_template(:new)
        end

      end

    end

    describe "GET 'order_transactions'" do

      before :each do
        order = create(:order_with_loyalty_points)
        Spree::Order.stub(:find_by).and_return(order)
      end

      it "assigns @loyalty_points" do
        get :order_transactions, :use_route => :spree, format: :json
        assigns[:loyalty_points].should_not be_nil
      end

      it "returns http success" do
        get :order_transactions, :use_route => :spree, format: :json
        response.should be_success
      end

    end

  end

  context "when user not found" do

    before(:each) do
      user = create(:user_with_loyalty_points)
      controller.stub(:spree_current_user).and_return(user)
      user.stub(:generate_spree_api_key!).and_return(true)
      controller.stub(:authorize!).and_return(true)
      controller.stub(:authorize_admin).and_return(true)
      Spree::User.stub(:find_by).and_return(nil)
      @loyalty_points_transaction = create(:loyalty_points_transaction)
      user.loyalty_points_transactions.stub(:create).and_return(@loyalty_points_transaction)
    end

    it "should redirect to users page" do
      get :index, :use_route => :spree
      expect(response).to redirect_to(admin_users_path)
    end
    
  end

end
