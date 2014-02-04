require "spec_helper"
#TODO -> Rspecs missing

describe Spree::ReturnAuthorization do

  before(:each) do
    @return_authorization = create(:return_authorization_with_loyalty_points)
    @return_authorization.order.stub(:loyalty_points_for).and_return(40)
  end

  describe 'update_loyalty_points' do

    #TODO -> We can test this by checking that order's update_loyalty_points should be called because this method is already tested in order model.
    it "should create a Loyalty Points Transaction" do
      expect {
        @return_authorization.update_loyalty_points
      }.to change{ Spree::LoyaltyPointsTransaction.count }.by(1)
    end

  end

end