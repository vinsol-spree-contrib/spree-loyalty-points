shared_examples_for "LoyaltyPoints" do

  describe 'loyalty_points_display' do

    it 'returns the same amount of points' do
      resource_instance.loyalty_points_display(100).should eq '100'
    end

  end

  describe 'loyalty_points_for' do

    context "when purpose is to award" do

      context "when eligible for being awarded" do

        before :each do
          @amount = 50
          resource_instance.stub(:eligible_for_loyalty_points?).with(@amount).and_return(true)
        end

        it "should return award amount" do
          resource_instance.loyalty_points_for(@amount, 'award').should eq((@amount * Spree::Config.loyalty_points_awarding_unit).floor)
        end

      end

      context "when ineligible for being awarded" do

        before :each do
          @amount = 0
          resource_instance.stub(:eligible_for_loyalty_points?).with(@amount).and_return(false)
        end

        it "should return 0" do
          resource_instance.loyalty_points_for(@amount, 'award').should eq(0)
        end
        
      end
      
    end

    context "when purpose is to redeem" do

      it "should return redeem amount" do
        resource_instance.loyalty_points_for(50, 'redeem').should eq((50 / Spree::Config.loyalty_points_conversion_rate).ceil)
      end
      
    end

    context "when purpose is neither to redeem nor award" do

      it "should return 0" do
        resource_instance.loyalty_points_for(50, 'other').should eq(0)
      end
      
    end

  end

  describe 'eligible_for_loyalty_points?' do

    before :each do
      Spree::Config.stub(:min_amount_required_to_get_loyalty_points).and_return(30)
    end

    context "when amount greater than min amount" do

      it "should return true" do
        resource_instance.send(:eligible_for_loyalty_points?, 40).should be_true
      end

    end

    context "when amount less than redeeming balance" do

      it "should return false" do
        resource_instance.send(:eligible_for_loyalty_points?, 20).should be_false
      end

    end

    context "when amount equal to redeeming balance" do

      it "should return false" do
        resource_instance.send(:eligible_for_loyalty_points?, 30).should be_true
      end

    end

  end

end
