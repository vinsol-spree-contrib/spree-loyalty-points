require 'spec_helper'

describe Spree::LoyaltyPointsController do

  let(:user) { mock_model(Spree::User).as_null_object }

  before(:each) do
    controller.stub(:spree_current_user).and_return(user)
    user.stub(:generate_spree_api_key!).and_return(true)
    controller.stub(:authorize!).and_return(true)
  end

  describe "GET 'index'" do
    def send_request(params = {})
      get :index, params.merge!(:use_route => :spree)
    end

    #TODO -> Check expectation of all methods.
    it "should receive loyalty_points_transactions on spree_current_user" do
      user.should_receive(:loyalty_points_transactions).and_return(user.loyalty_points_transactions)
      send_request
    end

    it "assigns @loyalty_points_transactions" do
      send_request
      assigns[:loyalty_points_transactions].should_not be_nil
    end

    it "renders index template" do
      send_request
      expect(response).to render_template(:index)
    end

  end

end
