require "spec_helper"

describe Spree::LoyaltyPointsTransaction, type: :model do

  before do
    @loyalty_points_transaction = FactoryGirl.build(:loyalty_points_debit_transaction)
  end

  describe 'validations' do

    before do
      @loyalty_points_transaction = FactoryGirl.build(:loyalty_points_debit_transaction)
      subject { LoyaltyPointsDebitTransaction.build }
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

    # it "is invalid if type is not in [Spree::LoyaltyPointsCreditTransaction, Spree::LoyaltyPointsDebitTransaction]" do
    #   should ensure_inclusion_of(:type).in_array(['Spree::LoyaltyPointsCreditTransaction', 'Spree::LoyaltyPointsDebitTransaction'])
    # end

    it "belongs_to user" do
      should belong_to(:user)
    end

    it "belongs_to source" do
      should belong_to(:source)
    end

end

  context "when neither source or comment is present" do

    before :each do
      @loyalty_points_transaction.source = nil
      @loyalty_points_transaction.comment = nil
      @loyalty_points_transaction.save
    end

    it "is invalid" do
      @loyalty_points_transaction.should_not be_valid
    end

    it "should add error 'Source or Comment should be present'" do
      @loyalty_points_transaction.errors[:base].include?('Source or Comment should be present').should be_truthy
    end

  end

  context "when source is present" do

    let(:order) { create(:order) }

    before :each do
      @loyalty_points_transaction.source = order
      @loyalty_points_transaction.comment = nil
      @loyalty_points_transaction.save
    end

    it "is valid" do
      @loyalty_points_transaction.should be_valid
    end

    it "should not add error 'Source or Comment should be present'" do
      @loyalty_points_transaction.errors[:base].include?('Source or Comment should be present').should be_falsey
    end

  end

  context "when comment is present" do

    before :each do
      @loyalty_points_transaction.source = nil
      @loyalty_points_transaction.comment = 'Random Comment'
      @loyalty_points_transaction.save
    end

    it "is valid" do
      @loyalty_points_transaction.should be_valid
    end

    it "should not add error 'Source or Comment should be present'" do
      @loyalty_points_transaction.errors[:base].include?('Source or Comment should be present').should be_falsey
    end

  end

  it "should include generate_transaction_id in before create callbacks" do
    Spree::LoyaltyPointsTransaction._create_callbacks.select { |callback| callback.kind == :before }.map(&:filter).include?(:generate_transaction_id).should be_truthy
  end

  describe "generate_transaction_id" do

    before :each do
      @time = Time.current
      @random1 = 23432
      Time.stub(:current).and_return(@time)
      @transaction_id = (@time.strftime("%s") + @random1.to_s).to(15)
    end

    context "when transaction_id does not exist earlier" do

      before :each do
        Spree::LoyaltyPointsTransaction.delete_all(transaction_id: @transaction_id)
        @loyalty_points_transaction.stub(:rand).with(999999).and_return(@random1)
        @loyalty_points_transaction.save
      end

      it "adds a transaction_id" do
        @loyalty_points_transaction.transaction_id.should eq(@transaction_id)
      end
      
    end

    context "when transaction_id exists earlier" do

      before :each do
        @random2 = 439795
        @loyalty_points_transaction.stub(:rand).with(999999).and_return(@random1, @random2)
        @transaction_id2 = (@time.strftime("%s") + @random2.to_s).to(15)
        Spree::LoyaltyPointsTransaction.delete_all(transaction_id: @transaction_id)
        loyalty_points_transaction2 = create(:loyalty_points_credit_transaction)
        loyalty_points_transaction2.update(transaction_id: @transaction_id)
        @loyalty_points_transaction.save
      end

      it "adds a transaction_id not equal to the existing one" do
        @loyalty_points_transaction.transaction_id.should eq(@transaction_id2)
      end

    end

  end

  describe 'for_order' do

    let (:order) { create(:order) }
    let (:transaction1) { create(:loyalty_points_credit_transaction, source: order) }
    let (:transaction2) { create(:loyalty_points_debit_transaction, source: nil, comment: 'Random') }

    before :each do
      Spree::LoyaltyPointsTransaction.destroy_all
    end

    it "should return payments where source is the given order" do
      Spree::LoyaltyPointsTransaction.for_order(order).should eq([transaction1])
    end

  end

  describe 'transaction_type' do

    context "when type is Spree::LoyaltyPointsCreditTransaction" do

      before :each do
        @loyalty_points_credit_transaction = FactoryGirl.build(:loyalty_points_credit_transaction)
      end

      it "should be Credit" do
        @loyalty_points_credit_transaction.transaction_type.should eq('Credit')
      end

    end

    context "when type is Spree::LoyaltyPointsDebitTransaction" do

      before :each do
        @loyalty_points_debit_transaction = FactoryGirl.build(:loyalty_points_debit_transaction)
      end

      it "should be Debit" do
        @loyalty_points_debit_transaction.transaction_type.should eq('Debit')
      end

    end

  end

  # describe "TransactionsTotalValidation" do
    
  #   before :each do
  #     @order = create(:order_with_loyalty_points)
  #     @loyalty_points_transaction = create(:loyalty_points_debit_transaction, source: @order)
  #   end

  #   it_should_behave_like "TransactionsTotalValidation" do
  #     let(:resource_instance) { @loyalty_points_transaction }
  #     let(:relation) { @loyalty_points_transaction.source }
  #   end

  # end

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
