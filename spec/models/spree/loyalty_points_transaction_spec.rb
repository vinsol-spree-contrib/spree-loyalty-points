require "spec_helper"

describe Spree::LoyaltyPointsTransaction, type: :model do

  let!(:loyalty_points_transaction) { build(:loyalty_points_debit_transaction) }

  describe 'validations' do

    subject { Spree::LoyaltyPointsDebitTransaction.new }

    it "is valid with valid attributes" do
      expect(loyalty_points_transaction).to be_valid
    end

    it "is invalid without numeric loyalty_points" do
      is_expected.to validate_numericality_of(:loyalty_points).only_integer.with_message(Spree.t('validation.must_be_int'))
      is_expected.to validate_numericality_of(:loyalty_points).is_greater_than(0).with_message(Spree.t('validation.must_be_int'))
    end

    it "is invalid without balance" do
      is_expected.to validate_presence_of :balance
    end

    it "belongs_to user" do
      is_expected.to belong_to(:user)
    end

    it "belongs_to source" do
      is_expected.to belong_to(:source)
    end

end

  context "when neither source or comment is present" do

    before :each do
      loyalty_points_transaction.source = nil
      loyalty_points_transaction.comment = nil
      loyalty_points_transaction.save
    end

    it "is invalid" do
      expect(loyalty_points_transaction).not_to be_valid
    end

    it "should add error 'Source or Comment should be present'" do
      expect(loyalty_points_transaction.errors[:base].include?('Source or Comment should be present')).to be_truthy
    end

  end

  context "when source is present" do

    let(:order) { create(:order) }

    before :each do
      loyalty_points_transaction.source = order
      loyalty_points_transaction.comment = nil
      loyalty_points_transaction.save
    end

    it "is valid" do
      expect(loyalty_points_transaction).to be_valid
    end

    it "should not add error 'Source or Comment should be present'" do
      expect(loyalty_points_transaction.errors[:base].include?('Source or Comment should be present')).to be_falsey
    end

  end

  context "when comment is present" do

    before :each do
      loyalty_points_transaction.source = nil
      loyalty_points_transaction.comment = 'Random Comment'
      loyalty_points_transaction.save
    end

    it "is valid" do
      expect(loyalty_points_transaction).to be_valid
    end

    it "should not add error 'Source or Comment should be present'" do
      expect(loyalty_points_transaction.errors[:base]).not_to include('Source or Comment should be present')
    end

  end

  it "should include generate_transaction_id in before create callbacks" do
    expect(Spree::LoyaltyPointsTransaction._create_callbacks.select { |callback| callback.kind == :before }.map(&:filter)).to include(:generate_transaction_id)
  end

  describe "generate_transaction_id" do

    before :each do
      @time = Time.current
      @random1 = 23432
      allow(Time).to receive(:current).and_return(@time)
      @transaction_id = (@time.strftime("%s") + @random1.to_s).to(15)
    end

    context "when transaction_id does not exist earlier" do

      before :each do
        Spree::LoyaltyPointsTransaction.delete_all(transaction_id: @transaction_id)
        allow(loyalty_points_transaction).to receive(:rand).with(999999).and_return(@random1)
        loyalty_points_transaction.save
      end

      it "adds a transaction_id" do
        expect(loyalty_points_transaction.transaction_id).to eq(@transaction_id)
      end
    end

    context "when transaction_id exists earlier" do

      before :each do
        @random2 = 439795
        allow(loyalty_points_transaction).to receive(:rand).with(999999).and_return(@random1, @random2)
        @transaction_id2 = (@time.strftime("%s") + @random2.to_s).to(15)
        Spree::LoyaltyPointsTransaction.delete_all(transaction_id: @transaction_id)
        loyalty_points_transaction2 = create(:loyalty_points_credit_transaction)
        loyalty_points_transaction2.update(transaction_id: @transaction_id)
        loyalty_points_transaction.save
      end

      it "adds a transaction_id not equal to the existing one" do
        expect(loyalty_points_transaction.transaction_id).to eq(@transaction_id2)
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
      expect(Spree::LoyaltyPointsTransaction.for_order(order)).to eq([transaction1])
    end

  end


  describe 'transaction_type' do
    let(:loyalty_points_debit_transaction) { FactoryGirl.build(:loyalty_points_debit_transaction) }
    let(:loyalty_points_credit_transaction) { FactoryGirl.build(:loyalty_points_credit_transaction) }

    context "when type is Spree::LoyaltyPointsCreditTransaction" do

      it "should be Credit" do
        expect(loyalty_points_credit_transaction.transaction_type).to eq('Credit')
      end

    end

    context "when type is Spree::LoyaltyPointsDebitTransaction" do

      it "should be Debit" do
        expect(loyalty_points_debit_transaction.transaction_type).to eq('Debit')
      end

    end

  end


  describe 'validate transactions_total_range' do
    let!(:order) { create(:order_with_loyalty_points) }
    let!(:loyalty_points_transaction) { create(:loyalty_points_debit_transaction, source: order) }

    def save_record
      loyalty_points_transaction.save
    end

    after :each do
      save_record
    end

    context "when source is present" do

      before :each do
        allow(loyalty_points_transaction.source).to receive(:present?).and_return(true)
      end

      context "when loyalty_points_transactions are present" do

        before :each do
          allow(loyalty_points_transaction.source.loyalty_points_transactions).to receive(:present?).and_return(true)
        end

        it "should receive transactions_total_range" do
          expect(loyalty_points_transaction).to receive(:transactions_total_range)
        end

        it "should receive validate_transactions_total_range" do
          expect(loyalty_points_transaction).to receive(:validate_transactions_total_range)
        end

      end

      context "when loyalty_points_transactions are absent" do

        before :each do
          allow(loyalty_points_transaction.source.loyalty_points_transactions).to receive(:present?).and_return(false)
        end

        it "should not receive transactions_total_range" do
          expect(loyalty_points_transaction).not_to receive(:transactions_total_range)
        end

      end

    end

    context "when source is absent" do

      before :each do
        allow(loyalty_points_transaction.source).to receive(:present?).and_return(false)
      end

      it "should not receive transactions_total_range" do
        expect(loyalty_points_transaction).not_to receive(:transactions_total_range)
      end

    end

  end

end
