require "spec_helper"

describe Spree::Order, type: :model do

  before(:each) do
    @order = create(:order_with_loyalty_points)
  end

  it "is valid with valid attributes" do
    expect(@order).to be_valid
  end

  describe "complete_loyalty_points_payments callback" do

    it "should be included in state_machine before callbacks" do
      expect(Spree::Order.state_machine.callbacks[:after].map { |callback| callback.instance_variable_get(:@methods) }.include?([:complete_loyalty_points_payments])).to be_truthy
    end

    it "should not include complete in 'from' states" do
      expect(Spree::Order.state_machine.callbacks[:after].select { |callback| callback.instance_variable_get(:@methods) == [:complete_loyalty_points_payments] }.first.branch.state_requirements.first[:from].values).to eq(Spree::Order.state_machines[:state].states.map(&:name) - [:complete])
    end

    it "should include only complete in 'to' states" do
      expect(Spree::Order.state_machine.callbacks[:after].select { |callback| callback.instance_variable_get(:@methods) == [:complete_loyalty_points_payments] }.first.branch.state_requirements.first[:to].values).to eq([:complete])
    end

  end

  it { is_expected.to have_many :loyalty_points_transactions }
  it { is_expected.to have_many :loyalty_points_credit_transactions }
  it { is_expected.to have_many :loyalty_points_debit_transactions }

  it_should_behave_like "LoyaltyPoints" do
    let(:resource_instance) { @order }
  end

  it_should_behave_like "Order::LoyaltyPoints" do
    let(:resource_instance) { @order }
  end

  describe 'loyalty_points_not_awarded' do

    let (:order2) { create(:order_with_loyalty_points) }

    before :each do
      @order.loyalty_points_credit_transactions = []
      order2.loyalty_points_credit_transactions = create_list(:loyalty_points_credit_transaction, 1, source: order2)
    end

    it "should return orders where loyalty points haven't been awarded" do
      expect(Spree::Order.loyalty_points_not_awarded).to eq([@order])
    end

  end

  describe 'with_hours_since_payment' do

    let (:order2) { create(:order_with_loyalty_points) }

    before :each do
      @order.paid_at = 4.hours.ago
      order2.paid_at = 1.hour.ago
      @order.save!
      order2.save!
    end

    it "should return orders where paid_at is before given time" do
      expect(Spree::Order.with_hours_since_payment(2)).to eq([@order])
    end

  end

  describe 'with_uncredited_loyalty_points' do

    let (:order2) { create(:order_with_loyalty_points) }
    let (:order3) { create(:order_with_loyalty_points) }

    before :each do
      @order.paid_at = 4.hours.ago
      @order.loyalty_points_credit_transactions = []
      order2.paid_at = 1.hour.ago
      order2.loyalty_points_credit_transactions = []
      order3.paid_at = 5.hours.ago
      order3.loyalty_points_credit_transactions = create_list(:loyalty_points_credit_transaction, 1, source: order2)
      @order.save!
      order2.save!
      order3.save!
    end

    it "should return orders where loyalty_points haven't been credited" do
      expect(Spree::Order.with_uncredited_loyalty_points(2)).to eq([@order])
    end

  end

end
