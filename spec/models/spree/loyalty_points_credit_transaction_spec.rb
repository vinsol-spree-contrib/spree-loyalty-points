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

  describe 'transaction_type' do

    before :each do
      @loyalty_points_credit_transaction = FactoryGirl.build(:loyalty_points_credit_transaction)
    end

    it "should be Credit" do
      @loyalty_points_credit_transaction.transaction_type.should eq('Credit')
    end

  end

  describe 'validate positive_loyalty_points_total' do

    def save_record
      @loyalty_points_credit_transaction.save
    end

    context "when source is present" do

      before :each do
        @order = create(:order_with_loyalty_points)
        @loyalty_points_credit_transaction.source = @order
      end

      context "when loyalty points are used" do

        before :each do
          @loyalty_points_credit_transaction.source.stub(:loyalty_points_used?).and_return(true)
          save_record
        end

        it "should not add any error" do
          @loyalty_points_credit_transaction.errors.should be_empty
        end

      end

      context "when loyalty points are not used" do

        before :each do
          @loyalty_points_credit_transaction.source.stub(:loyalty_points_used?).and_return(false)
        end

        context "when loyalty_points_credit_transactions are present" do

          before :each do
            @order.loyalty_points_credit_transactions = create_list(:loyalty_points_credit_transaction, 5)
            @order.loyalty_points_debit_transactions = create_list(:loyalty_points_debit_transaction, 5)
          end

          context "when negative_total is greater than positive_total" do

            before :each do
              @loyalty_points_credit_transaction.source.loyalty_points_credit_transactions.stub(:sum).and_return(50)
              @loyalty_points_credit_transaction.source.loyalty_points_debit_transactions.stub(:sum).and_return(1000)
              save_record
            end

            it "should add error 'Loyalty Points Total cannot be negative for this source'" do
              @loyalty_points_credit_transaction.errors[:base].should eq(["Loyalty Points Total cannot be negative for this source"])
            end

          end

          context "when negative_total is less than positive_total" do

            before :each do
              @loyalty_points_credit_transaction.source.loyalty_points_credit_transactions.stub(:sum).and_return(1000)
              @loyalty_points_credit_transaction.source.loyalty_points_debit_transactions.stub(:sum).and_return(20)
              save_record
            end

            it "should not add any error" do
              @loyalty_points_credit_transaction.errors.should be_empty
            end

          end

        end

        context "when loyalty_points_credit_transactions are absent" do

          before :each do
            @order.loyalty_points_credit_transactions = []
            @order.loyalty_points_debit_transactions = []
            save_record
          end

          it "should not add any error" do
            @loyalty_points_credit_transaction.errors.should be_empty
          end

        end

      end

    end

    context "when source is absent" do

      before :each do
        @loyalty_points_credit_transaction.source = nil
        save_record
      end

      it "should not add any error" do
        @loyalty_points_credit_transaction.errors.should be_empty
      end

    end

  end

end
