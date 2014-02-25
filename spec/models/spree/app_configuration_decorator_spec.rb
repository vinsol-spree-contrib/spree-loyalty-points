require "spec_helper"

describe Spree::AppConfiguration do

  it "should set preference min_amount_required_to_get_loyalty_points"  do
    Spree::Config.min_amount_required_to_get_loyalty_points.should eq(20.0)
  end

  it "should set preference loyalty_points_awarding_unit"  do
    Spree::Config.loyalty_points_awarding_unit.should eq(0.0)
  end

  it "should set preference loyalty_points_redeeming_balance"  do
    Spree::Config.loyalty_points_redeeming_balance.should eq(50)
  end

  it "should set preference loyalty_points_conversion_rate"  do
    Spree::Config.loyalty_points_conversion_rate.should eq(5.0)
  end

  it "should set preference loyalty_points_award_period"  do
    Spree::Config.loyalty_points_award_period.should eq(1)
  end

end