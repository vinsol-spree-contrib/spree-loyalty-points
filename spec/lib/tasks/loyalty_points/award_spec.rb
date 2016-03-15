require 'spec_helper'
require 'rake'

SpreeLoyaltyPoints::Engine.load_tasks

describe "Award Rake Task" do

  before do
    Rake::Task.define_task(:environment)
  end

  it 'should receive credit_loyalty_points_to_user on Spree::Order' do
    expect(Spree::Order).to receive(:credit_loyalty_points_to_user)
  end

  after do
    Rake.application.invoke_task "spree:loyalty_points:award"
  end

end