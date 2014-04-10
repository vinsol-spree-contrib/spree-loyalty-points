require "spec_helper"

describe Spree::Order do

  before(:each) do
    @order = create(:order_with_loyalty_points)
  end

  it "is valid with valid attributes" do
    @order.should be_valid
  end

  describe 'loyalty_points_eligible_total' do
    let(:line_items) do
      [ build(:line_item) ]
    end
    before do
      @order.line_items << line_items
    end

    subject { @order.loyalty_points_eligible_total }

    it 'is the same as item total' do
      @order.loyalty_points_eligible_total.should eq(line_items[0].amount)
    end

    context 'has multiple line items' do
      let(:line_items) do
        [ build(:line_item), build(:line_item) ]
      end
      it 'has the sum of all items' do
        @order.loyalty_points_eligible_total.should eq(line_items.map(&:amount).sum)
      end
    end

    context 'has loyalty point inelgible products' do
      let(:line_items) do
        [ build(:line_item), build(:line_item) ]
      end
      before do
        line_items.last.should_receive(:loyalty_points_eligible).and_return false
      end
      it 'does not count inelgible products' do
        @order.loyalty_points_eligible_total.should eq(line_items.first.amount)
      end
    end
  end

  describe "complete_loyalty_points_payments callback" do

    it "should be included in state_machine before callbacks" do
      Spree::Order.state_machine.callbacks[:before].map { |callback| callback.instance_variable_get(:@methods) }.include?([:complete_loyalty_points_payments]).should be_true
    end

    it "should not include complete in 'from' states" do
      Spree::Order.state_machine.callbacks[:before].select { |callback| callback.instance_variable_get(:@methods) == [:complete_loyalty_points_payments] }.first.branch.state_requirements.first[:from].values.should eq(Spree::Order.state_machines[:state].states.map(&:name) - [:complete])
    end

    it "should include only complete in 'to' states" do
      Spree::Order.state_machine.callbacks[:before].select { |callback| callback.instance_variable_get(:@methods) == [:complete_loyalty_points_payments] }.first.branch.state_requirements.first[:to].values.should eq([:complete])
    end

  end

  it { should have_many :loyalty_points_transactions }
  it { should have_many :loyalty_points_credit_transactions }
  it { should have_many :loyalty_points_debit_transactions }

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
      Spree::Order.loyalty_points_not_awarded.should eq([@order])
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
      Spree::Order.with_hours_since_payment(2).should eq([@order])
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
      Spree::Order.with_uncredited_loyalty_points(2).should eq([@order])
    end

  end

end
