require "spec_helper"
require "models/concerns/spree/transactions_total_validation_spec"

#TODO -> Rspecs still missing. Please check again.
describe Spree::LoyaltyPointsTransaction do

  before(:each) do
    @loyalty_points_transaction = FactoryGirl.build(:loyalty_points_debit_transaction)
  end

  it "is valid with valid attributes" do
    @loyalty_points_transaction.should be_valid
  end

  it "is invalid without numeric loyalty_points" do
    should validate_numericality_of(:loyalty_points).only_integer.with_message(Spree.t('validation.must_be_int'))
    should validate_numericality_of(:loyalty_points).is_greater_than(0).with_message(Spree.t('validation.must_be_int'))
  end

  it "is invalid without balance" do
    should validate_presence_of :balance
  end

  it "is invalid if type is not in [Spree::LoyaltyPointsCreditTransaction, Spree::LoyaltyPointsDebitTransaction]" do
    should ensure_inclusion_of(:type).in_array(['Spree::LoyaltyPointsCreditTransaction', 'Spree::LoyaltyPointsDebitTransaction'])
  end

  it "belongs_to user" do
    should belong_to(:user)
  end

  it "belongs_to source" do
    should belong_to(:source)
  end

  context "when neither source or comment is present" do

    before :each do
      @loyalty_points_transaction.source = nil
      @loyalty_points_transaction.comment = nil
    end

    it "is invalid" do
      @loyalty_points_transaction.should_not be_valid
    end

    it "should add error 'Source or Comment should be present'" do
      @loyalty_points_transaction.errors[:base].include? ('Source or Comment should be present').should be_true
    end

  end

  describe "generate_transaction_id" do

    before :each do
      @loyalty_points_transaction.send(:generate_transaction_id)
    end

    it "adds a transaction_id" do
      @loyalty_points_transaction.transaction_id.should_not be_nil
    end

  end

  describe "TransactionsTotalValidation" do
    
    before :each do
      @order = create(:order_with_loyalty_points)
      @loyalty_points_transaction = create(:loyalty_points_debit_transaction, source: @order)
    end

    it_should_behave_like "TransactionsTotalValidation" do
      let(:resource_instance) { @loyalty_points_transaction }
      let(:relation) { @loyalty_points_transaction.source }
    end

  end

  describe 'validate transactions_total_range' do

    before :each do
      @order = create(:order_with_loyalty_points)
      @loyalty_points_transaction = create(:loyalty_points_debit_transaction, source: @order)
    end

    def save_record
      @loyalty_points_transaction.save
    end

    after :each do
      save_record
    end

    context "when source is present" do

      before :each do
        @loyalty_points_transaction.source.stub(:present?).and_return(true)
      end

      context "when loyalty_points_transactions are present" do

        before :each do
          @loyalty_points_transaction.source.loyalty_points_transactions.stub(:present?).and_return(true)
        end

        it "should receive transactions_total_range" do
          @loyalty_points_transaction.should_receive(:transactions_total_range)
        end

        it "should receive validate_transactions_total_range" do
          @loyalty_points_transaction.should_receive(:validate_transactions_total_range)
        end

      end

      context "when loyalty_points_transactions are absent" do

        before :each do
          @loyalty_points_transaction.source.loyalty_points_transactions.stub(:present?).and_return(false)
        end

        it "should not receive transactions_total_range" do
          @loyalty_points_transaction.should_not_receive(:transactions_total_range)
        end

      end

    end

    context "when source is absent" do

      before :each do
        @loyalty_points_transaction.source.stub(:present?).and_return(false)
      end

      it "should not receive transactions_total_range" do
        @loyalty_points_transaction.should_not_receive(:transactions_total_range)
      end

    end

  end

end
