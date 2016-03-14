shared_examples_for "TransactionsTotalValidation" do

  describe "net_transactions_sum" do

    context "when transaction_type is Debit" do
      
      before :each do
        @trans_type = "Debit"
        @total = relation.loyalty_points_credit_transactions.sum(:loyalty_points) - relation.loyalty_points_debit_transactions.sum(:loyalty_points) - resource_instance.loyalty_points
      end

      it "should return total" do
        expect(resource_instance.send(:net_transactions_sum, @trans_type, relation)).to eq(@total)
      end

    end

    context "when transaction_type is Credit" do
      
      before :each do
        @trans_type = "Credit"
        @total = relation.loyalty_points_credit_transactions.sum(:loyalty_points) - relation.loyalty_points_debit_transactions.sum(:loyalty_points) + resource_instance.loyalty_points
      end

      it "should return total" do
        expect(resource_instance.send(:net_transactions_sum, @trans_type, relation)).to eq(@total)
      end

    end

  end

  describe "validate_transactions_total_range" do

    before :each do
      @first_transaction = create(:loyalty_points_debit_transaction)
      allow(relation.loyalty_points_transactions).to receive(:first).and_return(@first_transaction)
    end

    context "when transaction_type is Debit" do
      
      before :each do
        @trans_type = "Debit"
        allow(@first_transaction).to receive(:transaction_type).and_return(@trans_type)
      end

      context "when net_transactions_sum is below range" do

        before :each do
          allow(resource_instance).to receive(:net_transactions_sum).and_return(20)
          allow(@first_transaction).to receive(:loyalty_points).and_return(30)
        end

        it "should return total" do
          resource_instance.send(:validate_transactions_total_range, @trans_type, relation)
          expect(resource_instance.errors[:base].include?("Loyalty Points Net Debit Total should be in the range [0, #{ @first_transaction.loyalty_points }]")).to be_truthy
        end

      end

      context "when net_transactions_sum is within range" do

        before :each do
          allow(resource_instance).to receive(:net_transactions_sum).and_return(-10)
          allow(@first_transaction).to receive(:loyalty_points).and_return(30)
        end

        it "should return total" do
          resource_instance.send(:validate_transactions_total_range, @trans_type, relation)
          expect(resource_instance.errors[:base].include?("Loyalty Points Net Debit Total should be in the range [0, #{ @first_transaction.loyalty_points }]")).to be_falsey
        end

      end

      context "when net_transactions_sum is above range" do

        before :each do
          allow(resource_instance).to receive(:net_transactions_sum).and_return(-40)
          allow(@first_transaction).to receive(:loyalty_points).and_return(30)
        end

        it "should return total" do
          resource_instance.send(:validate_transactions_total_range, @trans_type, relation)
          expect(resource_instance.errors[:base].include?("Loyalty Points Net Debit Total should be in the range [0, #{ @first_transaction.loyalty_points }]")).to be_truthy
        end

      end

    end

    context "when transaction_type is Credit" do
      
      before :each do
        @trans_type = "Credit"
        allow(@first_transaction).to receive(:transaction_type).and_return(@trans_type)
      end

      context "when net_transactions_sum is below range" do

        before :each do
          allow(resource_instance).to receive(:net_transactions_sum).and_return(-20)
          allow(@first_transaction).to receive(:loyalty_points).and_return(30)
        end

        it "should return total" do
          resource_instance.send(:validate_transactions_total_range, @trans_type, relation)
          expect(resource_instance.errors[:base].include?("Loyalty Points Net Credit Total should be in the range [0, #{ @first_transaction.loyalty_points }]")).to be_truthy
        end

      end

      context "when net_transactions_sum is within range" do

        before :each do
          allow(resource_instance).to receive(:net_transactions_sum).and_return(20)
          allow(@first_transaction).to receive(:loyalty_points).and_return(30)
        end

        it "should return total" do
          resource_instance.send(:validate_transactions_total_range, @trans_type, relation)
          expect(resource_instance.errors[:base].include?("Loyalty Points Net Credit Total should be in the range [0, #{ @first_transaction.loyalty_points }]")).to be_falsey
        end

      end

      context "when net_transactions_sum is below range" do

        before :each do
          allow(resource_instance).to receive(:net_transactions_sum).and_return(40)
          allow(@first_transaction).to receive(:loyalty_points).and_return(30)
        end

        it "should return total" do
          resource_instance.send(:validate_transactions_total_range, @trans_type, relation)
          expect(resource_instance.errors[:base].include?("Loyalty Points Net Credit Total should be in the range [0, #{ @first_transaction.loyalty_points }]")).to be_truthy
        end

      end

    end

  end

end