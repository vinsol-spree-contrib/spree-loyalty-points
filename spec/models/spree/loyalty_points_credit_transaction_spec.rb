require "spec_helper"

describe Spree::LoyaltyPointsCreditTransaction do

  before(:each) do
    @loyalty_points_credit_transaction = build(:loyalty_points_credit_transaction)
  end

  it "is valid with valid attributes" do
    @loyalty_points_credit_transaction.should be_valid
  end

  #TODO -> We can use matchers to test these validations.
  it "is invalid without numeric loyalty_points" do
    should validate_numericality_of(:loyalty_points).only_integer.with_message(Spree.t('validation.must_be_int'))
    should validate_numericality_of(:loyalty_points).is_greater_than(0).with_message(Spree.t('validation.must_be_int'))
  end

  it "is invalid without balance" do
    should validate_presence_of :balance
  end

  it "is invalid if type is not in [Spree::LoyaltyPointsCreditTransaction]" do
    should ensure_inclusion_of(:type).in_array(['Spree::LoyaltyPointsCreditTransaction'])
  end

  it "belongs_to user" do
    should belong_to(:user)
  end

  it "belongs_to source" do
    should belong_to(:source)
  end

  #TODO -> Also check error message.
  context "when neither source or comment is present" do

    before :each do
      @loyalty_points_credit_transaction.source = nil
      @loyalty_points_credit_transaction.comment = nil
    end

    it "is invalid" do
      @loyalty_points_credit_transaction.should_not be_valid
    end

    it "should add error 'Source or Comment should be present'" do
      @loyalty_points_credit_transaction.errors[:base].include? ('Source or Comment should be present').should be_true
    end

  end

  describe 'update_user_balance' do

    before :each do
      @loyalty_points_credit_transaction = FactoryGirl.build(:loyalty_points_credit_transaction)
    end

    it "should increment user's loyalty_points_balance" do
      expect {
        @loyalty_points_credit_transaction.send(:update_user_balance)
      }.to change{ @loyalty_points_credit_transaction.user.loyalty_points_balance }.by(@loyalty_points_credit_transaction.loyalty_points)
    end

  end

  describe 'update_balance' do

    before :each do
      @loyalty_points_credit_transaction = FactoryGirl.build(:loyalty_points_credit_transaction)
      @loyalty_points_credit_transaction.send(:update_balance)
    end

    it "should set balance" do
      @loyalty_points_credit_transaction.balance.should_not be_nil 
    end

  end

  describe 'transaction_type' do

    before :each do
      @loyalty_points_credit_transaction = FactoryGirl.build(:loyalty_points_credit_transaction)
    end

    it "should be Credit" do
      @loyalty_points_credit_transaction.transaction_type.should eq('Credit')
    end

  end

  describe 'positive_loyalty_points_total' do

    context "when negative_total is greater than positive_total" do

      before :each do
        @order = create(:order_with_loyalty_points)
        @loyalty_points_credit_transaction.source = @order
        @order.loyalty_points_credit_transactions = create_list(:loyalty_points_credit_transaction, 5)
        @order.loyalty_points_debit_transactions = create_list(:loyalty_points_debit_transaction, 5)
        @loyalty_points_credit_transaction.source.loyalty_points_credit_transactions.stub(:sum).and_return(50)
        @loyalty_points_credit_transaction.source.loyalty_points_debit_transactions.stub(:sum).and_return(1000)
        @loyalty_points_credit_transaction.send(:positive_loyalty_points_total)
      end

      it "should add error 'Loyalty Points Total cannot be negative for this source'" do
        @loyalty_points_credit_transaction.errors[:base].should eq(["Loyalty Points Total cannot be negative for this source"])
      end

    end

    context "when negative_total is less than positive_total" do

      before :each do
        @order = create(:order_with_loyalty_points)
        @loyalty_points_credit_transaction.source = @order
        @order.loyalty_points_credit_transactions = create_list(:loyalty_points_credit_transaction, 5)
        @order.loyalty_points_debit_transactions = create_list(:loyalty_points_debit_transaction, 5)
        @loyalty_points_credit_transaction.source.loyalty_points_credit_transactions.stub(:sum).and_return(1000)
        @loyalty_points_credit_transaction.source.loyalty_points_debit_transactions.stub(:sum).and_return(20)
        @loyalty_points_credit_transaction.send(:positive_loyalty_points_total)
      end

      it "should not add any error" do
        @loyalty_points_credit_transaction.errors.should be_empty
      end

    end

  end

end
