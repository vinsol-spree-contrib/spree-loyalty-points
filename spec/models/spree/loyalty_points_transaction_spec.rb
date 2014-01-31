require "spec_helper"

describe Spree::LoyaltyPointsTransaction do

  before(:each) do
    @loyalty_points_transaction = FactoryGirl.build(:loyalty_points_debit_transaction)
  end

  it "is valid with valid attributes" do
    @loyalty_points_transaction.should be_valid
  end

  it "is invalid without loyalty_points" do
    @loyalty_points_transaction.loyalty_points = nil
    @loyalty_points_transaction.should_not be_valid
  end

  it "is invalid without balance" do
    @loyalty_points_transaction.balance = nil
    @loyalty_points_transaction.should_not be_valid
  end

  it "is invalid if transaction type not in [Debit, Credit]" do
    @loyalty_points_transaction.transaction_type = "XYZ"
    @loyalty_points_transaction.should_not be_valid
  end

  it "is invalid if neither source or comment is present" do
    @loyalty_points_transaction.source = nil
    @loyalty_points_transaction.comment = nil
    @loyalty_points_transaction.should_not be_valid
  end

  describe 'update_user_balance' do

    context "when transaction_type is Debit" do

      before :each do
        @loyalty_points_transaction.transaction_type = "Debit"
      end

      it "should decrement user's loyalty_points_balance" do
        expect {
          @loyalty_points_transaction.update_user_balance
        }.to change{ @loyalty_points_transaction.user.loyalty_points_balance}.by(-@loyalty_points_transaction.loyalty_points)
      end

    end

    context "when transaction_type is Credit" do

      before :each do
        @loyalty_points_transaction.transaction_type = "Credit"
      end

      it "should increment user's loyalty_points_balance" do
        expect {
          @loyalty_points_transaction.update_user_balance
        }.to change{ @loyalty_points_transaction.user.loyalty_points_balance}.by(@loyalty_points_transaction.loyalty_points)
      end

    end

    it "should change balance" do
      expect {
        @loyalty_points_transaction.update_user_balance
      }.to change{ @loyalty_points_transaction.balance}
    end

  end

  describe 'debit_transaction?' do

    context "when transaction_type is Debit" do

      before :each do
        @loyalty_points_transaction.transaction_type = "Debit"
      end

      it "should return true" do
        @loyalty_points_transaction.debit_transaction?.should eq(true)
      end

    end

    context "when transaction_type is not Debit" do

      before :each do
        @loyalty_points_transaction.transaction_type = "Credit"
      end

      it "should return false" do
        @loyalty_points_transaction.debit_transaction?.should eq(false)
      end

    end

  end

end
