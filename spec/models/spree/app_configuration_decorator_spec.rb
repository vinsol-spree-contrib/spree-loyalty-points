require "spec_helper"

describe Spree::AppConfiguration do

  it "should set preference min_amount_required_to_get_loyalty_points"  do
    expect(Spree::Config.min_amount_required_to_get_loyalty_points).to eq(20.0)
  end

  it "should set preference loyalty_points_awarding_unit"  do
    expect(Spree::Config.loyalty_points_awarding_unit).to eq(0.0)
  end

  it "should set preference loyalty_points_redeeming_balance"  do
    expect(Spree::Config.loyalty_points_redeeming_balance).to eq(50)
  end

  it "should set preference loyalty_points_conversion_rate"  do
    expect(Spree::Config.loyalty_points_conversion_rate).to eq(5.0)
  end

  it "should set preference loyalty_points_award_period"  do
    expect(Spree::Config.loyalty_points_award_period).to eq(1)
  end

end
