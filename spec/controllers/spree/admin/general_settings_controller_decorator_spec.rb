require 'spec_helper'

describe Spree::Admin::GeneralSettingsController do

  before(:each) do
    user = create(:user_with_loyalty_points)
    controller.stub(:spree_current_user).and_return(user)
    user.stub(:generate_spree_api_key!).and_return(true)
    controller.stub(:authorize!).and_return(true)
    controller.stub(:authorize_admin).and_return(true)
  end

  describe "GET 'edit'" do

    it "assigns @preferences_loyalty_points" do
      get :edit, :use_route => :spree
      assigns[:preferences_loyalty_points].should_not be_nil
    end

    it "renders edit template" do
      get :edit, :use_route => :spree
      expect(response).to render_template(:edit)
    end

  end

end
