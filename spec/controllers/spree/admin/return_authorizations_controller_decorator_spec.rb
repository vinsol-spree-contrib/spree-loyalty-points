#TODO -> Rspecs missing.
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

  describe "set_loyalty_points_transactions" do

    def send_request(params = {})
      get :new, params.merge!(:use_route => :spree)
    end

    it "assigns loyalty_points_transactions" do
      send_request
      assigns[:loyalty_points_transactions].should_not be_nil
    end
    
  end

end