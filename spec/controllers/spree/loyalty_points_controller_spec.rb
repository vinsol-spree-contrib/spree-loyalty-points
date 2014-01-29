require 'spec_helper'

describe Spree::LoyaltyPointsController do

  before(:each) do
    user = create(:user_with_loyalty_points)
    controller.stub(:spree_current_user).and_return(user)
    user.stub(:generate_spree_api_key!).and_return(true)
    controller.stub(:authorize!).and_return(true)
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

end
