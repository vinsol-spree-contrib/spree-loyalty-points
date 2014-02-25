shared_examples_for "TransactionsTotalValidation" do

  describe "net_transactions_sum" do

    context "when transaction_type is Debit" do
      
      before :each do
        @trans_type = "Debit"
        @total = relation.loyalty_points_credit_transactions.sum(:loyalty_points) - relation.loyalty_points_debit_transactions.sum(:loyalty_points) - resource_instance.loyalty_points
      end

      it "should return total" do
        resource_instance.send(:net_transactions_sum, @trans_type, relation).should eq(@total)
      end

    end

    context "when transaction_type is Credit" do
      
      before :each do
        @trans_type = "Credit"
        @total = relation.loyalty_points_credit_transactions.sum(:loyalty_points) - relation.loyalty_points_debit_transactions.sum(:loyalty_points) + resource_instance.loyalty_points
      end

      it "should return total" do
        resource_instance.send(:net_transactions_sum, @trans_type, relation).should eq(@total)
      end

    end

  end

  describe "validate_transactions_total_range" do

    before :each do
      @first_transaction = create(:loyalty_points_debit_transaction)
      relation.loyalty_points_transactions.stub(:first).and_return(@first_transaction)
    end

    context "when transaction_type is Debit" do
      
      before :each do
        @trans_type = "Debit"
        @first_transaction.stub(:transaction_type).and_return(@trans_type)
      end

      context "when net_transactions_sum is below range" do

        before :each do
          resource_instance.stub(:net_transactions_sum).and_return(20)
          @first_transaction.stub(:loyalty_points).and_return(30)
        end

        it "should return total" do
          resource_instance.send(:validate_transactions_total_range, @trans_type, relation)
          resource_instance.errors[:base].include?("Loyalty Points Net Debit Total should be in the range [0, #{ @first_transaction.loyalty_points }]").should be_true
        end

      end

      context "when net_transactions_sum is within range" do

        before :each do
          resource_instance.stub(:net_transactions_sum).and_return(-10)
          @first_transaction.stub(:loyalty_points).and_return(30)
        end

        it "should return total" do
          resource_instance.send(:validate_transactions_total_range, @trans_type, relation)
          resource_instance.errors[:base].include?("Loyalty Points Net Debit Total should be in the range [0, #{ @first_transaction.loyalty_points }]").should be_false
        end

      end

      context "when net_transactions_sum is above range" do

        before :each do
          resource_instance.stub(:net_transactions_sum).and_return(-40)
          @first_transaction.stub(:loyalty_points).and_return(30)
        end

        it "should return total" do
          resource_instance.send(:validate_transactions_total_range, @trans_type, relation)
          resource_instance.errors[:base].include?("Loyalty Points Net Debit Total should be in the range [0, #{ @first_transaction.loyalty_points }]").should be_true
        end

      end

    end

    context "when transaction_type is Credit" do
      
      before :each do
        @trans_type = "Credit"
        @first_transaction.stub(:transaction_type).and_return(@trans_type)
      end

      context "when net_transactions_sum is below range" do

        before :each do
          resource_instance.stub(:net_transactions_sum).and_return(-20)
          @first_transaction.stub(:loyalty_points).and_return(30)
        end

        it "should return total" do
          resource_instance.send(:validate_transactions_total_range, @trans_type, relation)
          resource_instance.errors[:base].include?("Loyalty Points Net Credit Total should be in the range [0, #{ @first_transaction.loyalty_points }]").should be_true
        end

      end

      context "when net_transactions_sum is within range" do

        before :each do
          resource_instance.stub(:net_transactions_sum).and_return(20)
          @first_transaction.stub(:loyalty_points).and_return(30)
        end

        it "should return total" do
          resource_instance.send(:validate_transactions_total_range, @trans_type, relation)
          resource_instance.errors[:base].include?("Loyalty Points Net Credit Total should be in the range [0, #{ @first_transaction.loyalty_points }]").should be_false
        end

      end

      context "when net_transactions_sum is below range" do

        before :each do
          resource_instance.stub(:net_transactions_sum).and_return(40)
          @first_transaction.stub(:loyalty_points).and_return(30)
        end

        it "should return total" do
          resource_instance.send(:validate_transactions_total_range, @trans_type, relation)
          resource_instance.errors[:base].include?("Loyalty Points Net Credit Total should be in the range [0, #{ @first_transaction.loyalty_points }]").should be_true
        end

      end

    end

  end

end