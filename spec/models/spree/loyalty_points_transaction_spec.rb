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
    @loyalty_points_transaction.type = "XYZ"
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
        @loyalty_points_transaction.type = "Spree::LoyaltyPointsDebitTransaction"
      end

      it "should decrement user's loyalty_points_balance" do
        expect {
          @loyalty_points_transaction.update_user_balance
        }.to change{ @loyalty_points_transaction.user.loyalty_points_balance}.by(-@loyalty_points_transaction.loyalty_points)
      end

    end

    context "when transaction_type is Credit" do

      before :each do
        @loyalty_points_transaction = FactoryGirl.build(:loyalty_points_transaction)
      end

      it "should increment user's loyalty_points_balance" do
        expect {
          @loyalty_points_transaction.update_user_balance
        }.to change{ @loyalty_points_transaction.user.loyalty_points_balance}.by(@loyalty_points_transaction.loyalty_points)
      end

    end

  end

  describe 'transaction_type' do

    context "when type is Spree::LoyaltyPointsDebitTransaction" do

      before :each do
        @loyalty_points_transaction.type = "Spree::LoyaltyPointsDebitTransaction"
      end

      it "should be Debit" do
        @loyalty_points_transaction.transaction_type.should eq('Debit')
      end

    end

    context "when type is Spree::LoyaltyPointsCreditTransaction" do

      before :each do
        @loyalty_points_transaction = FactoryGirl.build(:loyalty_points_transaction)
      end

      it "should be Credit" do
        @loyalty_points_transaction.transaction_type.should eq('Credit')
      end

    end

  end

end
