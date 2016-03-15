require "spec_helper"

describe Spree::ReturnAuthorization do

  let(:return_authorization) { create(:return_authorization_with_loyalty_points) }
  before(:each) do
    allow(return_authorization.order).to receive(:loyalty_points_for).and_return(40)
  end

  describe "update_loyalty_points callback" do

    it "should be included in state_machine after callbacks" do
      expect(Spree::ReturnAuthorization.state_machine.callbacks[:after].map { |callback| callback.instance_variable_get(:@methods) }.include?([:update_loyalty_points])).to be_truthy
    end

    it "should include only received in 'to' states" do
      expect(Spree::ReturnAuthorization.state_machine.callbacks[:after].select { |callback| callback.instance_variable_get(:@methods) == [:update_loyalty_points] }.first.branch.state_requirements.first[:to].values).to eq([:received])
    end

  end

  describe 'update_loyalty_points' do
    context "when loyalty_points_transaction_type is Debit" do

      before(:each) do
        return_authorization.loyalty_points_transaction_type = "Debit"
      end

      context "when user's balance is lowest" do

        before :each do
          allow(return_authorization.order).to receive(:loyalty_points_for).with(return_authorization.order.item_total).and_return(return_authorization.order.user.loyalty_points_balance + 10)
          allow(return_authorization).to receive(:loyalty_points).and_return(return_authorization.order.user.loyalty_points_balance + 20)
          @debit_points = return_authorization.order.user.loyalty_points_balance
        end

        it "should receive create_debit_transaction with user's balance" do
          expect(return_authorization.order).to receive(:create_debit_transaction).with(@debit_points)
          return_authorization.update_loyalty_points
        end

      end

      context "when loyalty_points_for is lowest" do

        before :each do
          @debit_points = return_authorization.order.loyalty_points_for(return_authorization.order.item_total)
          allow(return_authorization.order.user).to receive(:loyalty_points_balance).and_return(@debit_points + 10)
          allow(return_authorization).to receive(:loyalty_points).and_return(@debit_points + 20)
        end

        it "should receive create_debit_transaction with order's loyalty_points_for" do
          expect(return_authorization.order).to receive(:create_debit_transaction).with(@debit_points)
          return_authorization.update_loyalty_points
        end

      end

      context "when loyalty_points are lowest" do

        before :each do
          @debit_points = return_authorization.loyalty_points
          allow(return_authorization.order).to receive(:loyalty_points_for).with(return_authorization.order.item_total).and_return(@debit_points + 10)
          allow(return_authorization.order.user).to receive(:loyalty_points_balance).and_return(@debit_points + 20)
        end

        it "should receive create_debit_transaction with return_authorization's loyalty_points" do
          expect(return_authorization.order).to receive(:create_debit_transaction).with(@debit_points)
          return_authorization.update_loyalty_points
        end

      end

    end

    context "when loyalty_points_transaction_type is Credit" do

      before(:each) do
        return_authorization.loyalty_points_transaction_type = "Credit"
      end

      context "when loyalty_points_for is lowest" do

        before :each do
          @credit_points = return_authorization.order.loyalty_points_for(return_authorization.order.item_total)
          allow(return_authorization).to receive(:loyalty_points).and_return(@credit_points + 10)
        end

        it "should receive create_credit_transaction with order's loyalty_points_for" do
          expect(return_authorization.order).to receive(:create_credit_transaction).with(@credit_points)
          return_authorization.update_loyalty_points
        end

      end

    end

  end

  describe "TransactionsTotalValidation" do
    
    it_should_behave_like "TransactionsTotalValidation" do
      let(:resource_instance) { return_authorization }
      let(:relation) { return_authorization.order }
    end

  end

  describe 'validate transactions_total_range' do

    before :each do
      @order = create(:order_with_loyalty_points)
      return_authorization = build(:return_authorization_with_loyalty_points, order: @order)
    end

    def save_record
      return_authorization.save
    end

    after :each do
      save_record
    end

    context "when order is present" do

      before :each do
        allow(return_authorization.order).to receive(:present?).and_return(true)
      end

      context "when loyalty_points_transactions are present" do

        before :each do
          allow(return_authorization.order.loyalty_points_transactions).to receive(:present?).and_return(true)
        end

        it "should receive transactions_total_range" do
          expect(return_authorization).to receive(:transactions_total_range)
        end

        it "should receive validate_transactions_total_range" do
          expect(return_authorization).to receive(:validate_transactions_total_range)
        end

      end

      context "when loyalty_points_transactions are absent" do

        before :each do
          allow(return_authorization.order.loyalty_points_transactions).to receive(:present?).and_return(false)
        end

        it "should not receive transactions_total_range" do
          expect(return_authorization).not_to receive(:transactions_total_range)
        end

      end

    end

    context "when order is absent" do

      before :each do
        allow(return_authorization.order).to receive(:present?).and_return(false)
      end

      it "should not receive transactions_total_range" do
        expect(return_authorization).not_to receive(:transactions_total_range)
      end

    end

  end

end