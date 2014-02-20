require "spec_helper"

#TODO -> Rspecs missing

describe Spree::User do

  before(:each) do
    @user = FactoryGirl.build(:user_with_loyalty_points)
  end

  it "is valid with valid attributes" do
    @user.should be_valid
  end

  #TODO -> We can use matchers here.

  it { should have_many :loyalty_points_transactions }
  it { should have_many :loyalty_points_credit_transactions }
  it { should have_many :loyalty_points_debit_transactions }

  it "is invalid without numeric loyalty_points_balance" do
    should validate_numericality_of(:loyalty_points_balance).only_integer
    should validate_numericality_of(:loyalty_points_balance).is_greater_than(0)
  end

  describe 'loyalty_points_balance_sufficient?' do

    #TODO -> Also check when loyalty_points_balance equal to redeeming balance
    before :each do
      Spree::Config.stub(:loyalty_points_redeeming_balance).and_return(30)
    end

    context "when loyalty_points_balance greater than redeeming balance" do

      before :each do
        @user.loyalty_points_balance = 40
      end

      it "should return true" do
        @user.loyalty_points_balance_sufficient?.should eq(true)
      end

    end

    context "when loyalty_points_balance equal to redeeming balance" do

      before :each do
        @user.loyalty_points_balance = 30
      end

      it "should return true" do
        @user.loyalty_points_balance_sufficient?.should eq(true)
      end

    end

    context "when loyalty_points_balance less than redeeming balance" do

      before :each do
        @user.loyalty_points_balance = 20
      end

      it "should return false" do
        @user.loyalty_points_balance_sufficient?.should eq(false)
      end

    end

  end

  describe 'has_sufficient_loyalty_points?' do

    #TODO -> Also check when loyalty_points_equivalent_currency equal to order total

    before :each do
      @order = create(:order_with_loyalty_points)
      @order.total = BigDecimal.new(30.0, 2)
    end

    context "when loyalty_points_equivalent_currency greater than order total" do

      before :each do
        @user.stub(:loyalty_points_equivalent_currency).and_return(40)
      end

      it "should return true" do
        @user.has_sufficient_loyalty_points?(@order).should eq(true)
      end

    end

    context "when loyalty_points_equivalent_currency equal to order total" do

      before :each do
        @user.stub(:loyalty_points_equivalent_currency).and_return(30)
      end

      it "should return true" do
        @user.has_sufficient_loyalty_points?(@order).should eq(true)
      end

    end

    context "when loyalty_points_equivalent_currency less than order total" do

      before :each do
        @user.stub(:loyalty_points_equivalent_currency).and_return(20)
      end

      it "should return false" do
        @user.has_sufficient_loyalty_points?(@order).should eq(false)
      end

    end

  end

  describe 'loyalty_points_equivalent_currency' do

    let (:conversion_rate) { 5.0 }

    before :each do
      Spree::Config.stub(:loyalty_points_conversion_rate).and_return(conversion_rate)
    end

    it "should return balance * conversion_rate" do
      @user.loyalty_points_equivalent_currency.should eq(@user.loyalty_points_balance * conversion_rate)
    end

  end

end
