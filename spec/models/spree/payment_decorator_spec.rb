require "spec_helper"
require "models/concerns/spree/loyalty_points_spec"
require "models/concerns/spree/payment/loyalty_points_spec"

describe Spree::Payment do

  before(:each) do
    @payment = create(:payment_with_loyalty_points)
  end

  #TODO -> Write complete rspec with all things(eg: from states).
  describe "notify_paid_order callback" do

    it "should be included in state_machine after callbacks" do
      Spree::Payment.state_machine.callbacks[:after].map { |callback| callback.instance_variable_get(:@methods) }.include?([:notify_paid_order]).should be_true
    end

    it "should not include completed in 'from' states" do
      Spree::Payment.state_machine.callbacks[:after].select { |callback| callback.instance_variable_get(:@methods) == [:notify_paid_order] }.first.branch.state_requirements.first[:from].values.should eq(Spree::Payment.state_machines[:state].states.map(&:name) - [:completed])
    end

    it "should include only completed in 'to' states" do
      Spree::Payment.state_machine.callbacks[:after].select { |callback| callback.instance_variable_get(:@methods) == [:notify_paid_order] }.first.branch.state_requirements.first[:to].values.should eq([:completed])
    end

  end

  describe "redeem_loyalty_points callback" do

    it "should be included in state_machine after callbacks" do
      Spree::Payment.state_machine.callbacks[:after].map { |callback| callback.instance_variable_get(:@methods) }.include?([:redeem_loyalty_points]).should be_true
    end

    it "should not include completed in 'from' states" do
      Spree::Payment.state_machine.callbacks[:after].select { |callback| callback.instance_variable_get(:@methods) == [:redeem_loyalty_points] }.first.branch.state_requirements.first[:from].values.should eq(Spree::Payment.state_machines[:state].states.map(&:name) - [:completed])
    end

    it "should include only completed in 'to' states" do
      Spree::Payment.state_machine.callbacks[:after].select { |callback| callback.instance_variable_get(:@methods) == [:redeem_loyalty_points] }.first.branch.state_requirements.first[:to].values.should eq([:completed])
    end

    it "should have if condition of by_loyalty_points?" do
      Spree::Payment.state_machine.callbacks[:after].select { |callback| callback.instance_variable_get(:@methods) == [:redeem_loyalty_points] }.first.branch.if_condition.should eq(:by_loyalty_points?)
    end

  end

  describe "return_loyalty_points callback" do

    it "should be included in state_machine after callbacks" do
      Spree::Payment.state_machine.callbacks[:after].map { |callback| callback.instance_variable_get(:@methods) }.include?([:return_loyalty_points]).should be_true
    end

    it "should include only completed in 'from' states" do
      Spree::Payment.state_machine.callbacks[:after].select { |callback| callback.instance_variable_get(:@methods) == [:return_loyalty_points] }.first.branch.state_requirements.first[:from].values.should eq([:completed])
    end

    it "should not include completed in 'to' states" do
      Spree::Payment.state_machine.callbacks[:after].select { |callback| callback.instance_variable_get(:@methods) == [:return_loyalty_points] }.first.branch.state_requirements.first[:to].values.should eq(Spree::Payment.state_machines[:state].states.map(&:name) - [:completed])
    end

    it "should have if condition of by_loyalty_points?" do
      Spree::Payment.state_machine.callbacks[:after].select { |callback| callback.instance_variable_get(:@methods) == [:return_loyalty_points] }.first.branch.if_condition.should eq(:by_loyalty_points?)
    end

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

  describe 'state_not' do

    let (:payment1) { create(:payment_with_loyalty_points, state: 'checkout') }
    let (:payment2) { create(:payment_with_loyalty_points, state: 'pending') }

    before :each do
      Spree::Payment.destroy_all
    end

    it "should return payments where state is not complete when complete is passed" do
      Spree::Payment.state_not('checkout').should eq([payment2])
    end

    it "should return payments where state is not pending when pending is passed" do
      Spree::Payment.state_not('pending').should eq([payment1])
    end

  end

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

  describe 'invalidate_old_payments' do

    let (:payments) { create_list(:payment_with_loyalty_points, 5, state: "checkout") }

    before :each do
      order = create(:order_with_loyalty_points)
      @payment.order = order
      order.payments = payments + [@payment]
      order.payments.stub(:with_state).with('checkout').and_return(order.payments)
      order.payments.stub(:where).and_return(order.payments)
    end

    context "when payment not by loyalty points" do

      before :each do
        @payment.stub(:by_loyalty_points?).and_return(false)
      end

      it "should receive with_state on order.payments" do
        @payment.order.payments.should_receive(:with_state).with('checkout')
        @payment.send(:invalidate_old_payments)
      end

      it "should receive where on order.payments" do
        @payment.order.payments.should_receive(:where)
        @payment.send(:invalidate_old_payments)
      end

      it "should receive invalidate" do
        @payment.should_receive(:invalidate!)
        @payment.send(:invalidate_old_payments)
      end

    end

    context "when payment by loyalty points" do

      before :each do
        @payment.stub(:by_loyalty_points?).and_return(true)
      end

      it "should not receive with_state on order.payments" do
        @payment.order.payments.should_not_receive(:with_state)
        @payment.send(:invalidate_old_payments)
      end

    end

  end

  it_should_behave_like "LoyaltyPoints" do
    let(:resource_instance) { @payment }
  end

  it_should_behave_like "Payment::LoyaltyPoints" do
    let(:resource_instance) { @payment }
  end

end
