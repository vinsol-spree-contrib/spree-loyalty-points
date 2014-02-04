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
          @payment.notify_paid_order
        }.to change{ @payment.order.paid_at }
      end

    end

    context "all payments not completed" do

      before :each do
        @payment.stub(:all_payments_completed?).and_return(false)
      end

      it "should change paid_at in order" do
        expect {
          @payment.notify_paid_order
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
        @payment.all_payments_completed?.should eq(true)
      end

    end

    context "one of the payments incomplete" do

      before :each do
        order = create(:order_with_loyalty_points)
        @payment.order = order
        payments.first.state = "void"
        order.payments = payments
      end

      it "should return true" do
        @payment.all_payments_completed?.should eq(false)
      end

    end

  end

end
