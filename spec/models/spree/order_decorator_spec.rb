require "spec_helper"

#TODO -> Missing rspecs.

describe Spree::Order do

  before(:each) do
    @order = create(:order_with_loyalty_points)
  end

  it "is valid with valid attributes" do
    @order.should be_valid
  end

  # TODO -> We can should receive the methods that have been tested separately.
  describe 'add_loyalty_points' do

    context "when payment not done via Loyalty Points" do

      before :each do
        @order.stub(:payment_by_loyalty_points?).and_return(false)
        @order.stub(:loyalty_points_for).and_return(50)
      end

      it "should add a Loyalty Points Transaction" do
        expect {
          @order.add_loyalty_points
        }.to change{ Spree::LoyaltyPointsTransaction.count }.by(1)
      end

    end

    context "when payment done via Loyalty Points" do

      before :each do
        @order.stub(:payment_by_loyalty_points?).and_return(true)
      end

      it "should not add a Loyalty Points Transaction" do
        expect {
          @order.add_loyalty_points
        }.to change{ Spree::LoyaltyPointsTransaction.count }.by(0)
      end

    end

  end

  describe 'redeem_loyalty_points' do

  #TODO -> Also test this context that loyaty points are redeemable or not redeemable.
    context "when payment done via Loyalty Points" do

      before :each do
        @order.stub(:payment_by_loyalty_points?).and_return(true)
        @order.stub(:redeemable_loyalty_points_balance?).and_return(true)
        @order.stub(:loyalty_points_for).and_return(50)
      end

      it "should add a Loyalty Points Transaction" do
        expect {
          @order.redeem_loyalty_points
        }.to change{ Spree::LoyaltyPointsTransaction.count }.by(1)
      end

    end

    context "when payment not done via Loyalty Points" do

      before :each do
        @order.stub(:payment_by_loyalty_points?).and_return(false)
      end

      it "should not add a Loyalty Points Transaction" do
        expect {
          @order.redeem_loyalty_points
        }.to change{ Spree::LoyaltyPointsTransaction.count }.by(0)
      end

    end

  end

  describe 'update_loyalty_points' do

    before :each do
      @order.stub(:quantity).and_return(30)
      @order.stub(:trans_type).and_return('Debit')
      @order.stub(:loyalty_points_for).and_return(50)
    end

    it "should add a Loyalty Points Transaction" do
      expect {
        @order.add_loyalty_points
      }.to change{ Spree::LoyaltyPointsTransaction.count }.by(1)
    end

  end

  describe 'new_loyalty_points_transaction' do

    context "when quantity is not 0" do
      
      it "should add a Loyalty Points Transaction" do
        expect {
          @order.new_loyalty_points_transaction(30, 'Spree::LoyaltyPointsCreditTransaction')
        }.to change{ Spree::LoyaltyPointsTransaction.count }.by(1)
      end

    end

    context "when quantity is 0" do
      
      it "should not add a Loyalty Points Transaction" do
        expect {
          @order.new_loyalty_points_transaction(0, 'Spree::LoyaltyPointsDebitTransaction')
        }.to change{ Spree::LoyaltyPointsTransaction.count }.by(0)
      end

    end

  end

  describe 'loyalty_points_for' do

    context "when purpose is to award" do

      #TODO -> Update this context.
      context "when ineligible for being awarded" do

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


  end

  describe 'redeemable_loyalty_points_balance?' do

    before :each do
      Spree::Config.stub(:loyalty_points_redeeming_balance).and_return(30)
    end

    context "when amount greater than redeeming balance" do

      it "should return true" do
        @order.redeemable_loyalty_points_balance?(40).should eq(true)
      end

    end

    context "when amount less than redeeming balance" do

      it "should return false" do
        @order.redeemable_loyalty_points_balance?(20).should eq(false)
      end

    end

  end

  describe 'loyalty_points_awarded?' do

    context "when credit transactions are present" do

      before :each do
        @order.loyalty_points_credit_transactions = create_list(:loyalty_points_transaction, 5, source: @order)
      end

      it "should return true" do
        #TODO -> We can use be_loyalty_points_awarded.
        @order.loyalty_points_awarded?.should eq(true)
      end

    end

    context "when credit transactions are absent" do

      before :each do
        @order.loyalty_points_credit_transactions = []
      end

      it "should return false" do
        @order.loyalty_points_awarded?.should eq(false)
      end

    end

  end

end
