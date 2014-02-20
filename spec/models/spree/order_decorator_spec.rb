require "spec_helper"

#TODO -> Missing rspecs.

describe Spree::Order do

  before(:each) do
    @order = create(:order_with_loyalty_points)
  end

  it "is valid with valid attributes" do
    @order.should be_valid
  end

  it { should have_many :loyalty_points_transactions }
  it { should have_many :loyalty_points_credit_transactions }
  it { should have_many :loyalty_points_debit_transactions }

  # TODO -> We can should receive the methods that have been tested separately.
  describe 'award_loyalty_points' do

    context "when payment not done via Loyalty Points" do

      before :each do
        @order.stub(:loyalty_points_used?).and_return(false)
        @order.stub(:loyalty_points_for).and_return(50)
      end

      it "should receive create_credit_transaction" do
        @order.should_receive(:create_credit_transaction)
        @order.award_loyalty_points
      end

    end

    context "when payment done via Loyalty Points" do

      before :each do
        @order.stub(:loyalty_points_used?).and_return(true)
      end

      it "should not receive create_credit_transaction" do
        @order.should_not_receive(:create_credit_transaction)
        @order.award_loyalty_points
      end

    end

  end

  describe 'create_credit_transaction' do

    context "when quantity is not 0" do
      
      it "should add a Loyalty Points Credit Transaction" do
        expect {
          @order.send(:create_credit_transaction, 30)
        }.to change{ Spree::LoyaltyPointsCreditTransaction.count }.by(1)
      end

    end

    context "when quantity is 0" do
      
      it "should not add a Loyalty Points Credit Transaction" do
        expect {
          @order.send(:create_credit_transaction, 0)
        }.to change{ Spree::LoyaltyPointsCreditTransaction.count }.by(0)
      end

    end

  end

  describe 'create_debit_transaction' do

    context "when quantity is not 0" do
      
      it "should add a Loyalty Points Debit Transaction" do
        expect {
          @order.send(:create_debit_transaction, 30)
        }.to change{ Spree::LoyaltyPointsDebitTransaction.count }.by(1)
      end

    end

    context "when quantity is 0" do
      
      it "should not add a Loyalty Points Debit Transaction" do
        expect {
          @order.send(:create_debit_transaction, 0)
        }.to change{ Spree::LoyaltyPointsDebitTransaction.count }.by(0)
      end

    end

  end

  describe 'loyalty_points_used?' do

    it "should receive any_with_loyalty_points? on payments" do
      @order.payments.should_receive(:any_with_loyalty_points?)
      @order.loyalty_points_used?
    end

  end

  describe 'complete_loyalty_points_payments' do

    before :each do
      @order.payments.stub(:by_loyalty_points).and_return(@order.payments)
      @order.payments.stub(:with_state).with('checkout').and_return(@order.payments)
    end

    it "should receive by_loyalty_points on payments" do
      @order.payments.should_receive(:by_loyalty_points)
      @order.send(:complete_loyalty_points_payments)
    end

    it "should receive with_state on payments" do
      @order.payments.by_loyalty_points.should_receive(:with_state).with('checkout')
      @order.send(:complete_loyalty_points_payments)
    end

  end

  describe 'credit_loyalty_points_to_user' do

    before :each do
      Spree::Config.stub(:loyalty_points_award_period).and_return(1)
      Spree::Order.stub(:with_uncredited_loyalty_points).and_return([@order])
    end

    it "should receive award_loyalty_points" do
      @order.should_receive(:award_loyalty_points)
      Spree::Order.credit_loyalty_points_to_user
    end

  end

  describe 'loyalty_points_for' do

    context "when purpose is to award" do

      #TODO -> Update this context.
      context "when eligible for being awarded" do

        before :each do
          @order.stub(:eligible_for_loyalty_points?).and_return(true)
        end

        it "should return award amount" do
          @order.loyalty_points_for(50, 'award').should eq((50 * Spree::Config.loyalty_points_awarding_unit).floor)
        end

      end

      context "when ineligible for being awarded" do

        before :each do
          @order.stub(:eligible_for_loyalty_points?).and_return(false)
        end

        it "should return 0" do
          @order.loyalty_points_for(0, 'award').should eq(0)
        end
        
      end
      
    end

    context "when purpose is to redeem" do

      it "should return redeem amount" do
        @order.loyalty_points_for(50, 'redeem').should eq((50 / Spree::Config.loyalty_points_conversion_rate).ceil)
      end
      
    end

    context "when purpose is neither to redeem" do

      it "should return redeem amount" do
        @order.loyalty_points_for(50, 'redeem').should eq((50 / Spree::Config.loyalty_points_conversion_rate).ceil)
      end
      
    end


  end

  describe 'loyalty_points_awarded?' do

    context "when credit transactions are present" do

      it "should return true" do
        #TODO -> We can use be_loyalty_points_awarded.
        @order.should be_loyalty_points_awarded
      end

    end

    context "when credit transactions are absent" do

      before :each do
        @order.loyalty_points_credit_transactions = []
      end

      it "should return false" do
        @order.should_not be_loyalty_points_awarded
      end

    end

  end

  describe 'loyalty_points_total' do

    before :each do
      @order.loyalty_points_credit_transactions = create_list(:loyalty_points_credit_transaction, 5, loyalty_points: 50)
      @order.loyalty_points_debit_transactions = create_list(:loyalty_points_debit_transaction, 5, loyalty_points: 30)
    end

    it "should result in net loyalty points for that order" do
      @order.loyalty_points_total.should eq(100)
    end

  end

end
