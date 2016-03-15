require "spec_helper"

describe Spree::LoyaltyPointsDebitTransaction do

  let(:loyalty_points_debit_transaction) { build(:loyalty_points_debit_transaction) }

  it "is valid with valid attributes" do
    expect(loyalty_points_debit_transaction).to be_valid
  end

  describe 'update_user_balance' do

    it "should decrement user's loyalty_points_balance" do
      expect {
        loyalty_points_debit_transaction.send(:update_user_balance)
      }.to change{ loyalty_points_debit_transaction.user.loyalty_points_balance }.by(-loyalty_points_debit_transaction.loyalty_points)
    end

  end

  describe 'update_balance' do
    let(:user_balance) { 300 }

    before :each do
      allow(loyalty_points_debit_transaction.user).to receive(:loyalty_points_balance).and_return(user_balance)
      loyalty_points_debit_transaction.send(:update_balance)
    end

    it "should set balance" do
      expect(loyalty_points_debit_transaction.balance).to eq(user_balance - loyalty_points_debit_transaction.loyalty_points)
    end

  end

end