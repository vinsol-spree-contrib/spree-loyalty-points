#TODO -> Rspecs missing for before_action.
require 'spec_helper'

describe Spree::Admin::ReturnAuthorizationsController do

  let(:return_authorization) { mock_model(Spree::ReturnAuthorization).as_null_object }

  before :each do
    @user = return_authorization.order.user
    controller.stub(:load_resource_instance).and_return(return_authorization)
    controller.stub(:spree_current_user).and_return(@user)
    controller.stub(:authorize!).and_return(true)
    controller.stub(:authorize_admin).and_return(true)
  end

  describe "set_loyalty_points_transactions callback" do

    it "should be included in before action callbacks" do
      Spree::Admin::ReturnAuthorizationsController._process_action_callbacks.select{ |callback| callback.kind == :before }.map(&:filter).include?(:set_loyalty_points_transactions).should be_true
    end

    it "should have only option set to [:new, :edit, :create, :update]" do
      ([:new, :edit, :create, :update] - Spree::Admin::ReturnAuthorizationsController._process_action_callbacks.select{ |callback| callback.filter == :set_loyalty_points_transactions }.first.options[:only]).should be_empty
    end

  end

  describe "set_loyalty_points_transactions" do

    before :each do
      @loyalty_points_transactions = return_authorization.order.loyalty_points_transactions
      return_authorization.order.stub(:loyalty_points_transactions).and_return(@loyalty_points_transactions)
      @loyalty_points_transactions.stub(:page).and_return(@loyalty_points_transactions)
      @loyalty_points_transactions.stub(:per).and_return(@loyalty_points_transactions)
    end

    def send_request(params = {})
      get :new, params.merge!(:use_route => :spree)
    end

    it "assigns loyalty_points_transactions" do
      send_request
      assigns[:loyalty_points_transactions].should eq(@loyalty_points_transactions)
    end

    it "should receive loyalty_points_transactions on order" do
      return_authorization.order.should_receive(:loyalty_points_transactions)
      send_request
    end

    it "should receive page on loyalty_points_transactions" do
      @loyalty_points_transactions.should_receive(:page).with('2')
      send_request(page: 2)
    end

    context "when per_page is passed as a parameter" do

      it "should receive per with per_page on loyalty_points_transactions" do
        @loyalty_points_transactions.should_receive(:per).with('20')
        send_request(per_page: 20)
      end

    end

    context "when per_page is not passed as a parameter" do

      it "should receive per with Spree::Config[:orders_per_page] on loyalty_points_transactions" do
        @loyalty_points_transactions.should_receive(:per).with(Spree::Config[:orders_per_page])
        send_request
      end

    end

  end

end