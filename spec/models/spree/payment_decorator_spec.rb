require "spec_helper"

#TODO -> rspecs missing
describe Spree::Payment do

  before(:each) do
    @payment = create(:payment_with_loyalty_points)
  end

  describe 'notify_paid_order' do

    context "all payments completed" do

      before :each do
        @payment.stub(:all_payments_completed?).and_return(true)
      end

      it "should change paid_at in order" do
        expect {
          @payment.send(:notify_paid_order)
        }.to change{ @payment.order.paid_at }
      end

    end

    context "all payments not completed" do

      before :each do
        @payment.stub(:all_payments_completed?).and_return(false)
      end

      it "should change paid_at in order" do
        expect {
          @payment.send(:notify_paid_order)
        }.to_not change{ @payment.order.paid_at }
      end

    end

  end


  #TODO -> Test state_not scope separately.
  describe 'all_payments_completed?' do

    let (:payments) { create_list(:payment_with_loyalty_points, 5, state: "completed") }

    context "all payments complete" do

      before :each do
        order = create(:order_with_loyalty_points)
        @payment.order = order
        order.payments = payments
      end

      it "should return true" do
        @payment.send(:all_payments_completed?).should eq(true)
      end

    end

    context "one of the payments incomplete" do

      before :each do
        order = create(:order_with_loyalty_points)
        @payment.order = order
        payments.first.state = "void"
        order.payments = payments
      end

      it "should return false" do
        @payment.send(:all_payments_completed?).should eq(false)
      end

    end

  end

  describe 'any_with_loyalty_points?' do

    let (:payments) { create_list(:payment_with_loyalty_points, 5, state: "completed") }

    context "when payment made using loyalty points" do

      before :each do
        Spree::Payment.stub(:by_loyalty_points).and_return(payments)
      end

      it "should return true" do
        Spree::Payment.any_with_loyalty_points?.should eq(true)
      end

    end

    context "when payment not made using loyalty points" do

      before :each do
        Spree::Payment.stub(:by_loyalty_points).and_return([])
      end

      it "should return false" do
        Spree::Payment.any_with_loyalty_points?.should eq(false)
      end

    end

  end

  describe 'invalidate_old_payments' do

    let (:payments) { create_list(:payment_with_loyalty_points, 5, state: "checkout") }

    before :each do
      order = create(:order_with_loyalty_points)
      @payment.order = order
      order.payments = payments + [@payment]
      order.payments.stub(:with_state).with('checkout').and_return(order.payments)
      order.payments.stub(:where).and_return(order.payments)
    end

    it "should receive with_state on order.payments" do
      @payment.order.payments.should_receive(:with_state).with('checkout')
      @payment.send(:invalidate_old_payments)
    end

    it "should receive where on order.payments" do
      @payment.order.payments.should_receive(:where)
      @payment.send(:invalidate_old_payments)
    end

    #TODO -> Check only loyalty_points payments should invalidate.
    it "should receive invalidate" do
      @payment.should_receive(:invalidate!)
      @payment.send(:invalidate_old_payments)
    end

  end

  describe 'redeem_loyalty_points' do

    context "when payment done via Loyalty Points" do

      before :each do
        @payment.stub(:by_loyalty_points?).and_return(true)
        @payment.stub(:loyalty_points_for).and_return(50)
      end

      context "when Loyalty Points are redeemable" do

        before :each do
          @payment.stub(:redeemable_loyalty_points_balance?).and_return(true)
        end

        #TODO -> Also check with how much loyalty_points debit transaction is created.
        it "should receive create_debit_transaction on order" do
          @payment.order.should_receive(:create_debit_transaction)
          @payment.send(:redeem_loyalty_points)
        end

      end

      context "when Loyalty Points are not redeemable" do

        before :each do
          @payment.stub(:redeemable_loyalty_points_balance?).and_return(false)
        end

        it "should not receive create_debit_transaction on order" do
          @payment.order.should_not_receive(:create_debit_transaction)
          @payment.send(:redeem_loyalty_points)
        end

      end

    end

    context "when payment not done via Loyalty Points" do

      before :each do
        @payment.stub(:by_loyalty_points?).and_return(false)
      end

      it "should not receive create_debit_transaction on order" do
        @payment.order.should_not_receive(:create_debit_transaction)
        @payment.send(:redeem_loyalty_points)
      end

    end

  end

  describe 'return_loyalty_points' do

    before :each do
      @payment.stub(:loyalty_points_for).and_return(30)
      order = create(:order_with_loyalty_points)
      @payment.order = order
      @loyalty_points_redeemed = @payment.loyalty_points_for(@payment.amount, 'redeem')
    end

    it "should receive create_credit_transaction on order" do
      @payment.order.should_receive(:create_credit_transaction).with(@loyalty_points_redeemed)
      @payment.send(:return_loyalty_points)
    end

  end

  #TODO -> Also write rspecs when payment's amount equal to redeeming balance.
  describe 'redeemable_loyalty_points_balance?' do

    before :each do
      Spree::Config.stub(:loyalty_points_redeeming_balance).and_return(30)
    end

    context "when amount greater than redeeming balance" do

      before :each do
        @payment.amount = 40
      end

      it "should return true" do
        @payment.send(:redeemable_loyalty_points_balance?).should be_true
      end

    end

    context "when amount less than redeeming balance" do

      before :each do
        @payment.amount = 20
      end

      it "should return false" do
        @payment.send(:redeemable_loyalty_points_balance?).should be_false
      end

    end

  end

  describe 'by_loyalty_points' do

    let (:payments) { create_list(:payment_with_loyalty_points, 5, state: "checkout") }

    before :each do
      Spree::Payment.stub(:joins).and_return(payments)
      payments.stub(:where).and_return(payments)
    end

    it "should receive joins" do
      Spree::Payment.should_receive(:joins)
      Spree::Payment.by_loyalty_points
    end

    #TODO -> Check actual query of database(i.e. actual fetching of records).
    it "should receive where" do
      payments.should_receive(:where)
      Spree::Payment.by_loyalty_points
    end

  end
end
