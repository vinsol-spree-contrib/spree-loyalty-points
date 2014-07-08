require 'spec_helper'

describe Spree::PaymentMethod::LoyaltyPoints do

  let(:loyalty_points_payment_method) { Spree::PaymentMethod::LoyaltyPoints.create!(:environment => Rails.env, :active => true, :name => 'Loyalty_Points') }
  let(:payment) { Spree::Payment.new(:amount => 50.0) }

  before(:each) do
    user = create(:user_with_loyalty_points)
    @order = create(:order_with_loyalty_points)
    payment.order = @order
    @order.user = user
    payment.payment_method = loyalty_points_payment_method
    payment.save!
    Spree::Order.stub(:find_by_number).and_return(@order)
  end
  
  describe 'actions' do
    it 'should return actions' do
      loyalty_points_payment_method.actions.should eq(['capture', 'void'])
    end
  end
  
  describe 'can_void?' do
    context 'when payment state is not void' do
      before(:each) do
        payment.state = 'pending'
        payment.save!
      end

      it 'should return true if payment can be void' do
        loyalty_points_payment_method.can_void?(payment).should eq(true)
      end
    end

    context 'when payment state is void' do
      before(:each) do
        payment.state = 'void'
        payment.save!
      end

      it 'should return false if payment cannot be void' do
        loyalty_points_payment_method.can_void?(payment).should eq(false)
      end
    end
  end

  describe 'void' do

    let(:source) { nil }
    let(:gateway) { { order_id: @order.id.to_s + "-123456"  } }

    before :each do
      Spree::Order.stub(:find_by_number).and_return(@order)
      @order.stub(:loyalty_points_for).and_return(30)
    end

    it 'should be a new ActiveMerchant::Billing::Response' do
      loyalty_points_payment_method.void(source, gateway).should be_a(ActiveMerchant::Billing::Response)
    end

    it 'should receive new on ActiveMerchant::Billing::Response with true, "", {}, {}' do
      ActiveMerchant::Billing::Response.should_receive(:new).with(true, "", {}, {}).and_call_original
      loyalty_points_payment_method.void(source, gateway)
    end

  end
  
  describe 'can_capture?' do
    context 'when payment state is one of [checkout, pending]' do
      before(:each) do
        payment.state = 'pending'
        payment.save!
      end

      it 'should return true if payment can be captured' do
        loyalty_points_payment_method.can_capture?(payment).should eq(true)
      end
    end

    context 'when payment state is void' do
      before(:each) do
        payment.state = 'void'
        payment.save!
      end

      it 'should return false if payment cannot be captured' do
        loyalty_points_payment_method.can_capture?(payment).should eq(false)
      end
    end
  end

  describe 'capture' do

    let(:source) { nil }
    let(:gateway) { { order_id: @order.id.to_s + "-123456"  } }

    it 'should be a new ActiveMerchant::Billing::Response' do
      loyalty_points_payment_method.capture(payment, source, gateway).should be_a(ActiveMerchant::Billing::Response)
    end

    it 'should receive new on ActiveMerchant::Billing::Response with true, "", {}, {}' do
      ActiveMerchant::Billing::Response.should_receive(:new).with(true, "", {}, {}).and_call_original
      loyalty_points_payment_method.capture(payment, source, gateway)
    end

  end
  
  describe 'source_required?' do
    it 'should return false' do
      loyalty_points_payment_method.should_not be_source_required
    end
  end

  describe '#guest_checkout?' do
    it 'should not allow this payment method in guest checkout' do
      loyalty_points_payment_method.guest_checkout?.should be_false
    end
  end
end