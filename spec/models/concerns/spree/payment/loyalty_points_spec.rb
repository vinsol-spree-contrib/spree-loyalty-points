shared_examples_for "Payment::LoyaltyPoints" do

  describe 'by_loyalty_points' do

    let(:loyalty_points_payment_method) { Spree::PaymentMethod::LoyaltyPoints.create!(:environment => Rails.env, :active => true, :name => 'LoyaltyPoints') }
    let(:check_payment_method) { Spree::PaymentMethod::Check.create!(:environment => Rails.env, :active => true, :name => 'Check') }
    let (:payment1) { create(:payment_with_loyalty_points, payment_method: loyalty_points_payment_method) }
    let (:payment2) { create(:payment_with_loyalty_points, payment_method: check_payment_method) }

    it "should return payments with loyalty_points payment method" do
      Spree::Payment.by_loyalty_points.should eq([payment1])
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

  describe 'redeem_loyalty_points' do

    before :each do
      resource_instance.stub(:by_loyalty_points?).and_return(true)
      resource_instance.stub(:loyalty_points_for).and_return(55)
    end

    it "should receive create_debit_transaction on order" do
      resource_instance.order.should_receive(:create_debit_transaction)
      resource_instance.send(:redeem_loyalty_points)
    end

    it "should create loyalty_points_debit_transaction on order" do
      resource_instance.send(:redeem_loyalty_points)
      Spree::LoyaltyPointsDebitTransaction.last.loyalty_points.should eq(55)
    end

  end

  describe 'return_loyalty_points' do

    before :each do
      resource_instance.stub(:loyalty_points_for).and_return(30)
      order = create(:order_with_loyalty_points)
      resource_instance.order = order
      @loyalty_points_redeemed = resource_instance.loyalty_points_for(resource_instance.amount, 'redeem')
    end

    it "should receive create_credit_transaction on order" do
      resource_instance.order.should_receive(:create_credit_transaction).with(@loyalty_points_redeemed)
      resource_instance.send(:return_loyalty_points)
    end

    it "should create loyalty_points_credit_transaction on order" do
      resource_instance.send(:return_loyalty_points)
      Spree::LoyaltyPointsCreditTransaction.last.loyalty_points.should eq(30)
    end

  end

  describe 'by_loyalty_points?' do
    
    let(:loyalty_points_payment_method) { Spree::PaymentMethod::LoyaltyPoints.create!(:environment => Rails.env, :active => true, :name => 'LoyaltyPoints') }
    let(:check_payment_method) { Spree::PaymentMethod::Check.create!(:environment => Rails.env, :active => true, :name => 'Check') }

    context "when payment_method type is LoyaltyPoints" do

      before :each do
        resource_instance.payment_method = loyalty_points_payment_method
      end

      it "should return true" do
        resource_instance.send(:by_loyalty_points?).should be_true
      end

    end

    context "when payment_method type is not LoyaltyPoints" do

      before :each do
        resource_instance.payment_method = check_payment_method
      end

      it "should return false" do
        resource_instance.send(:by_loyalty_points?).should be_false
      end

    end

  end

  describe 'redeemable_loyalty_points_balance?' do

    before :each do
      Spree::Config.stub(:loyalty_points_redeeming_balance).and_return(30)
    end

    context "when amount greater than redeeming balance" do

      before :each do
        resource_instance.order.user.loyalty_points_balance = 40
      end

      it "should return true" do
        resource_instance.send(:redeemable_loyalty_points_balance?).should be_true
      end

    end

    context "when amount less than redeeming balance" do

      before :each do
        resource_instance.order.user.loyalty_points_balance = 20
      end

      it "should return false" do
        resource_instance.send(:redeemable_loyalty_points_balance?).should be_false
      end

    end

    context "when amount equal to redeeming balance" do

      before :each do
        resource_instance.order.user.loyalty_points_balance = 30
      end

      it "should return false" do
        resource_instance.send(:redeemable_loyalty_points_balance?).should be_true
      end

    end

  end

  describe 'redeemable_user_balance' do

    context "when Loyalty Points are redeemable" do

      before :each do
        resource_instance.stub(:redeemable_loyalty_points_balance?).and_return(true)
      end

      it "should not add errors to loyalty_points_balance" do
        resource_instance.send(:redeemable_user_balance)
        resource_instance.errors[:loyalty_points_balance].should be_empty
      end

    end

    context "when Loyalty Points are not redeemable" do

      before :each do
        resource_instance.stub(:redeemable_loyalty_points_balance?).and_return(false)
        Spree::Config.stub(:loyalty_points_redeeming_balance).and_return(30)
        resource_instance.order.user.stub(:loyalty_points_balance).and_return(20)
      end
      
      it "should add error to loyalty_points_balance" do
        min_balance = Spree::Config.loyalty_points_redeeming_balance
        resource_instance.send(:redeemable_user_balance)
        resource_instance.errors[:loyalty_points_balance].should eq(["should be atleast #{ min_balance.to_s + " " + "point".pluralize(min_balance) } for redeeming Loyalty Points"])
      end

    end

  end

end