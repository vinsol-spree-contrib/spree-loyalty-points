require 'spec_helper'

describe Spree::Admin::LoyaltyPointsTransactionsController do

  let(:user) { mock_model(Spree::User).as_null_object }
  let(:loyalty_points_transaction) { mock_model(Spree::LoyaltyPointsCreditTransaction).as_null_object }
  let(:order) { mock_model(Spree::Order).as_null_object }

  before(:each) do
    controller.stub(:spree_current_user).and_return(user)
    user.stub(:generate_spree_api_key!).and_return(true)
    controller.stub(:authorize!).and_return(true)
    controller.stub(:authorize_admin).and_return(true)
    user.loyalty_points_transactions.stub(:create).and_return(loyalty_points_transaction)
    controller.stub(:parent_data).and_return({ :model_name => 'spree/order', :model_class => Spree::Order, :find_by => 'id' })
  end

  def default_host
    { :host => "http://test.host" }
  end

  describe "set_user callback" do

    it "should be included in before action callbacks" do
      Spree::Admin::LoyaltyPointsTransactionsController._process_action_callbacks.select{ |callback| callback.kind == :before }.map(&:filter).include?(:set_user).should be_true
    end

    it "should have only option set to [:order_transactions]" do
      ([:order_transactions] - Spree::Admin::LoyaltyPointsTransactionsController._process_action_callbacks.select{ |callback| callback.filter == :set_user }.first.options[:only]).should be_empty
    end

  end

  describe "set_ordered_transactions callback" do

    it "should be included in before action callbacks" do
      Spree::Admin::LoyaltyPointsTransactionsController._process_action_callbacks.select{ |callback| callback.kind == :before }.map(&:filter).include?(:set_ordered_transactions).should be_true
    end

    it "should have only option set to [:index]" do
      ([:index] - Spree::Admin::LoyaltyPointsTransactionsController._process_action_callbacks.select{ |callback| callback.filter == :set_ordered_transactions }.first.options[:only]).should be_empty
    end

  end

  context "when user found" do

    before(:each) do
      controller.stub(:parent).and_return(user)
      Spree::User.stub(:find_by).and_return(user)
    end

    describe "GET 'index'" do
      def send_request(params = {})
        get :index, params.merge!(:use_route => :spree)
      end

      it "assigns @loyalty_points_transactions" do
        send_request
        assigns[:loyalty_points_transactions].should_not be_nil
      end

      it "@user should receive loyalty_points_transactions" do
        user.should_receive(:loyalty_points_transactions)
        send_request
      end

      it "renders index template" do
        send_request
        expect(response).to render_template(:index)
      end

    end

    describe "POST 'create'" do
      def send_request(params = {})
        post :create, params.merge!(loyalty_points_transaction: attributes_for(:loyalty_points_transaction), :use_route => :spree)
      end

      before :each do
        controller.stub(:load_resource_instance).and_return(loyalty_points_transaction)
      end

      it "assigns @loyalty_points_transaction" do
        send_request
        assigns[:loyalty_points_transaction].should_not be_nil
      end

      it "@loyalty_points_transaction should receive save" do
        loyalty_points_transaction.should_receive(:save)
        send_request
      end

      context "when transaction created " do

        before(:each) do
          controller.stub(:parent).and_return(user)
          controller.instance_variable_set(:@parent, user)
          send_request
        end

        it "redirects to admin users loyalty points page" do
          expect(response).to redirect_to(admin_user_loyalty_points_url(user, default_host))
        end

      end

      context "when transaction failed " do

        before :each do
          controller.stub(:load_resource_instance).and_return(loyalty_points_transaction)
          loyalty_points_transaction.stub(:save).and_return(false)
        end

        it "renders new template" do
          post :create, loyalty_points_transaction: attributes_for(:loyalty_points_credit_transaction), user_id: "1", :use_route => :spree
          expect(response).to render_template(:new)
        end

      end

    end

  end

  context "when user not found" do

    before(:each) do
      Spree::User.stub(:find_by).and_return(nil)
      controller.stub(:parent).and_raise(ActiveRecord::RecordNotFound)
    end

    it "should redirect to user's loyalty points page" do
      get :index, :use_route => :spree
      expect(response).to redirect_to(admin_users_path)
    end
    
  end

  describe "collection_url" do
    
    context "when parent_data is present" do
      
      before(:each) do
        controller.stub(:parent_data).and_return({ :model_name => 'spree/order', :model_class => Spree::Order, :find_by => 'id' })
      end

      context "when parent is nil" do
        
        before(:each) do
          controller.instance_variable_set(:@parent, nil)
        end

        it "should return admin_users_url" do
          controller.send(:collection_url).should eq(admin_users_url(default_host))
        end

      end

      context "when parent is not nil" do
        
        before(:each) do
          controller.instance_variable_set(:@parent, user)
        end

        it "should return admin_users_url" do
          controller.send(:collection_url).should eq(admin_user_loyalty_points_url(user, default_host))
        end

      end

    end 

    context "when parent_data is absent" do
      
      before(:each) do
        controller.stub(:parent_data).and_return({})
      end

      it "should return admin_users_url" do
        controller.send(:collection_url).should eq(admin_users_url(default_host))
      end

    end

  end

  describe "association_name" do
    
    before :each do
      @class_name = "Spree::LoyaltyPointsDebitTransaction"
    end

    it "should receive gsub on klass" do
      @class_name.should_receive(:gsub).with('Spree::', '').and_return('LoyaltyPointsDebitTransaction')
      controller.send(:association_name, @class_name)
    end
  end

  describe "build_resource" do

    context "when params[:loyalty_points_transaction][:type] is present" do
      
      before :each do
        controller.stub(:params).and_return({ :loyalty_points_transaction => { :type => 'Spree::LoyaltyPointsCreditTransaction' } })
        controller.stub(:parent).and_return(user)
        controller.stub(:association_name).and_return("loyalty_points_credit_transactions")
      end

      it "should receive send on parent" do
        user.should_receive(:send).with("loyalty_points_credit_transactions")
        controller.send(:build_resource)
      end

    end

    context "when params[:loyalty_points_transaction][:type] is absent" do
      
      before :each do
        controller.stub(:params).and_return({})
        controller.stub(:parent).and_return(user)
        controller.stub(:controller_name).and_return("loyalty_points_transactions")
      end

      it "should receive send on parent" do
        user.should_receive(:send).with("loyalty_points_transactions")
        controller.send(:build_resource)
      end

    end

  end

  describe "GET 'order_transactions'" do
    def send_request(params = {})
      get :order_transactions, params.merge!(loyalty_points_transaction: attributes_for(:loyalty_points_transaction), :use_route => :spree, format: :json)
    end

    before :each do
      Spree::Order.stub(:find_by).and_return(order)
    end

    context "when user is found" do
      
      before(:each) do
        controller.stub(:parent).and_return(user)
        Spree::User.stub(:find_by).and_return(user)
        send_request
      end

      it "should redirect_to admin_users_path" do
        expect(response).to_not redirect_to(admin_users_path)
      end

      it "assigns @loyalty_points_transactions" do
        assigns[:loyalty_points_transactions].should_not be_nil
      end

      it "should be http success" do
        response.should be_success
      end

    end

    context "when user is not found" do
      
      before :each do
        Spree::User.stub(:find_by).and_return(nil)
        send_request
      end

      it "should redirect_to admin_users_path" do
        expect(response).to redirect_to(admin_users_path)
      end

    end

  end
end
