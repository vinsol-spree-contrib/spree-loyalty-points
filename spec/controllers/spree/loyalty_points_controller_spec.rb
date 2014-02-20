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

    before(:each) do
      send_request
    end

    #TODO -> Check expectation of all methods.
    it "assigns @loyalty_points" do
      assigns[:loyalty_points_transactions].should_not be_nil
    end

    it "renders index template" do
      expect(response).to render_template(:index)
    end

  end

end
