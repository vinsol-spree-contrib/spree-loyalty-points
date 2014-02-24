require "spec_helper"

describe Spree::PaymentMethod do

  let(:payment_method) { mock_model(Spree::PaymentMethod).as_null_object }
  let(:payment_methods) { [payment_method] }

  #TODO -> Check this for actaul queries.
  describe "loyalty_points_id_included?" do
    
    before :each do
      Spree::PaymentMethod.stub(:where).and_return(payment_methods)
      payment_methods.stub(:where).and_return(payment_methods)
    end

    after :each do
      Spree::PaymentMethod.loyalty_points_id_included?([1, 2])
    end

    it "should receive where with type: Spree::PaymentMethod::LoyaltyPoints" do
      Spree::PaymentMethod.should_receive(:where).with(type: 'Spree::PaymentMethod::LoyaltyPoints').and_return(payment_methods)
    end

    it "should receive where with id: method_ids array" do
      payment_methods.should_receive(:where).and_return(payment_methods)
    end

    it "should receive size" do
      payment_methods.should_receive(:size).and_return(1)
    end

  end

end
