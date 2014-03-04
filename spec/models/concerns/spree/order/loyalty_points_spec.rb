shared_examples_for "Order::LoyaltyPoints" do

  describe 'award_loyalty_points' do

    context "when payment not done via Loyalty Points" do

      before :each do
        resource_instance.stub(:loyalty_points_used?).and_return(false)
        resource_instance.stub(:loyalty_points_for).and_return(50)
      end

      it "should receive create_credit_transaction" do
        resource_instance.should_receive(:create_credit_transaction)
        resource_instance.award_loyalty_points
      end

    end

    context "when payment done via Loyalty Points" do

      before :each do
        resource_instance.stub(:loyalty_points_used?).and_return(true)
      end

      it "should not receive create_credit_transaction" do
        resource_instance.should_not_receive(:create_credit_transaction)
        resource_instance.award_loyalty_points
      end

    end

  end

  describe 'create_credit_transaction' do

    context "when quantity is not 0" do
      
      it "should add a Loyalty Points Credit Transaction" do
        expect {
          resource_instance.send(:create_credit_transaction, 30)
        }.to change{ Spree::LoyaltyPointsCreditTransaction.count }.by(1)
      end

      it "should create a Loyalty Points Credit Transaction" do
        resource_instance.send(:create_credit_transaction, 30)
        Spree::LoyaltyPointsCreditTransaction.last.loyalty_points.should eq(30)
      end

      it "should create a Loyalty Points Credit Transaction" do
        resource_instance.send(:create_credit_transaction, 30)
        Spree::LoyaltyPointsCreditTransaction.last.user_id.should eq(resource_instance.user_id)
      end

    end

    context "when quantity is 0" do
      
      it "should not add a Loyalty Points Credit Transaction" do
        expect {
          resource_instance.send(:create_credit_transaction, 0)
        }.to change{ Spree::LoyaltyPointsCreditTransaction.count }.by(0)
      end

    end

  end

  describe 'create_debit_transaction' do

    context "when quantity is not 0" do
      
      it "should add a Loyalty Points Debit Transaction" do
        expect {
          resource_instance.send(:create_debit_transaction, 30)
        }.to change{ Spree::LoyaltyPointsDebitTransaction.count }.by(1)
      end

      it "should create a Loyalty Points Debit Transaction" do
        resource_instance.send(:create_debit_transaction, 30)
        Spree::LoyaltyPointsDebitTransaction.last.loyalty_points.should eq(30)
      end

      it "should create a Loyalty Points Credit Transaction" do
        resource_instance.send(:create_debit_transaction, 30)
        Spree::LoyaltyPointsDebitTransaction.last.user_id.should eq(resource_instance.user_id)
      end

    end

    context "when quantity is 0" do
      
      it "should not add a Loyalty Points Debit Transaction" do
        expect {
          resource_instance.send(:create_debit_transaction, 0)
        }.to change{ Spree::LoyaltyPointsDebitTransaction.count }.by(0)
      end

    end

  end

  describe 'loyalty_points_used?' do

    it "should receive any_with_loyalty_points? on payments" do
      resource_instance.payments.should_receive(:any_with_loyalty_points?)
      resource_instance.loyalty_points_used?
    end

  end

  describe 'complete_loyalty_points_payments' do

    before :each do
      resource_instance.payments.stub(:by_loyalty_points).and_return(resource_instance.payments)
      resource_instance.payments.stub(:with_state).with('checkout').and_return(resource_instance.payments)
    end

    it "should receive by_loyalty_points on payments" do
      resource_instance.payments.should_receive(:by_loyalty_points)
      resource_instance.send(:complete_loyalty_points_payments)
    end

    it "should receive with_state on payments" do
      resource_instance.payments.by_loyalty_points.should_receive(:with_state).with('checkout')
      resource_instance.send(:complete_loyalty_points_payments)
    end

    it "should receive complete on each payment" do
      resource_instance.payments.each do |payment|
        payment.should_receive(:complete!)
      end
      resource_instance.send(:complete_loyalty_points_payments)
    end

  end

  describe 'credit_loyalty_points_to_user' do

    before :each do
      Spree::Config.stub(:loyalty_points_award_period).and_return(1)
      Spree::Order.stub(:with_uncredited_loyalty_points).and_return([resource_instance])
    end

    it "should receive award_loyalty_points" do
      resource_instance.should_receive(:award_loyalty_points)
      Spree::Order.credit_loyalty_points_to_user
    end

  end

  describe 'loyalty_points_awarded?' do

    context "when credit transactions are present" do

      it "should return true" do
        resource_instance.should be_loyalty_points_awarded
      end

    end

    context "when credit transactions are absent" do

      before :each do
        resource_instance.loyalty_points_credit_transactions = []
      end

      it "should return false" do
        resource_instance.should_not be_loyalty_points_awarded
      end

    end

  end

  describe 'loyalty_points_total' do

    before :each do
      resource_instance.loyalty_points_credit_transactions = create_list(:loyalty_points_credit_transaction, 1, loyalty_points: 50)
      resource_instance.loyalty_points_debit_transactions = create_list(:loyalty_points_debit_transaction, 1, loyalty_points: 30)
    end

    it "should result in net loyalty points for that order" do
      resource_instance.loyalty_points_total.should eq(20)
    end

  end

end
