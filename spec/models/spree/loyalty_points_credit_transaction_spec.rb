require "spec_helper"

describe Spree::LoyaltyPointsCreditTransaction do

  before(:each) do
    @loyalty_points_credit_transaction = build(:loyalty_points_credit_transaction)
  end

  it "is valid with valid attributes" do
    @loyalty_points_credit_transaction.should be_valid
  end

  describe 'update_user_balance' do

    it "should increment user's loyalty_points_balance" do
      expect {
        @loyalty_points_credit_transaction.send(:update_user_balance)
      }.to change{ @loyalty_points_credit_transaction.user.loyalty_points_balance }.by(@loyalty_points_credit_transaction.loyalty_points)
    end

  end

  describe 'update_balance' do

    before :each do
      @user_balance = 300
      @loyalty_points_credit_transaction.user.stub(:loyalty_points_balance).and_return(@user_balance)
      @loyalty_points_credit_transaction.send(:update_balance)
    end

    it "should set balance" do
      @loyalty_points_credit_transaction.balance.should eq(@user_balance + @loyalty_points_credit_transaction.loyalty_points)
    end

  end

end
