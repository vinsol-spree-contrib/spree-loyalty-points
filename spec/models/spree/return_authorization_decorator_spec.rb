require "spec_helper"
#TODO -> Rspecs missing

describe Spree::ReturnAuthorization do

  before(:each) do
    @return_authorization = create(:return_authorization_with_loyalty_points)
    @return_authorization.order.stub(:loyalty_points_for).and_return(40)
  end

  #TODO -> Write different test cases after considering each thing minimum in different case.
  describe 'update_loyalty_points' do
    context "when loyalty_points_transaction_type is Debit" do

      before(:each) do
        @return_authorization.loyalty_points_transaction_type = "Debit"
        @debit_points = [@return_authorization.order.user.loyalty_points_balance, @return_authorization.order.loyalty_points_for(@return_authorization.order.item_total), @return_authorization.loyalty_points].min
      end

      it "should receive create_debit_transaction" do
        @return_authorization.order.should_receive(:create_debit_transaction).with(@debit_points)
        @return_authorization.update_loyalty_points
      end

    end

    context "when loyalty_points_transaction_type is Credit" do

      before(:each) do
        @return_authorization.loyalty_points_transaction_type = "Credit"
        @credit_points = [@return_authorization.order.loyalty_points_for(@return_authorization.order.total), @return_authorization.loyalty_points].min
      end

      it "should receive create_credit_transaction" do
        @return_authorization.order.should_receive(:create_credit_transaction).with(@credit_points)
        @return_authorization.update_loyalty_points
      end

    end

  end

  describe 'positive_loyalty_points_total' do

    context "when negative_total is greater than positive_total" do

      before :each do
        @order = create(:order_with_loyalty_points)
        @return_authorization.order = @order
        @order.loyalty_points_credit_transactions = create_list(:loyalty_points_credit_transaction, 5)
        @order.loyalty_points_debit_transactions = create_list(:loyalty_points_debit_transaction, 5)
        @return_authorization.order.loyalty_points_credit_transactions.stub(:sum).and_return(50)
        @return_authorization.order.loyalty_points_debit_transactions.stub(:sum).and_return(1000)
        @return_authorization.send(:positive_loyalty_points_total)
      end

      it "should add error 'Loyalty Points Total cannot be negative for this source'" do
        @return_authorization.errors[:base].should eq(["Loyalty Points Total cannot be negative for this order"])
      end

    end

    context "when negative_total is less than positive_total" do

      before :each do
        @order = create(:order_with_loyalty_points)
        @return_authorization.order = @order
        @order.loyalty_points_credit_transactions = create_list(:loyalty_points_credit_transaction, 5)
        @order.loyalty_points_debit_transactions = create_list(:loyalty_points_debit_transaction, 5)
        @return_authorization.order.loyalty_points_credit_transactions.stub(:sum).and_return(1000)
        @return_authorization.order.loyalty_points_debit_transactions.stub(:sum).and_return(20)
        @return_authorization.send(:positive_loyalty_points_total)
      end

      it "should not add any error" do
        @return_authorization.errors.should be_empty
      end

    end

  end

  describe 'negative_loyalty_points_total' do

    context "when negative_total is less than positive_total" do

      before :each do
        @order = create(:order_with_loyalty_points)
        @return_authorization.order = @order
        @order.loyalty_points_credit_transactions = create_list(:loyalty_points_credit_transaction, 5)
        @order.loyalty_points_debit_transactions = create_list(:loyalty_points_debit_transaction, 5)
        @return_authorization.order.loyalty_points_credit_transactions.stub(:sum).and_return(1000)
        @return_authorization.order.loyalty_points_debit_transactions.stub(:sum).and_return(30)
        @return_authorization.send(:negative_loyalty_points_total)
      end

      it "should add error 'Loyalty Points Total cannot be negative for this source'" do
        @return_authorization.errors[:base].should eq(["Loyalty Points Total cannot be positive for this order"])
      end

    end

    context "when negative_total is greater than positive_total" do

      before :each do
        @order = create(:order_with_loyalty_points)
        @return_authorization.order = @order
        @order.loyalty_points_credit_transactions = create_list(:loyalty_points_credit_transaction, 5)
        @order.loyalty_points_debit_transactions = create_list(:loyalty_points_debit_transaction, 5)
        @return_authorization.order.loyalty_points_credit_transactions.stub(:sum).and_return(50)
        @return_authorization.order.loyalty_points_debit_transactions.stub(:sum).and_return(1000)
        @return_authorization.send(:negative_loyalty_points_total)
      end

      it "should not add any error" do
        @return_authorization.errors.should be_empty
      end

    end

  end


end