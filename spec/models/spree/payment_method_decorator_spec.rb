require "spec_helper"

describe Spree::PaymentMethod do

  let(:loyalty_points_payment_method) { Spree::PaymentMethod::LoyaltyPoints.create!(active: true, name: 'Loyalty_Points') }
  let(:payment_method2) { Spree::PaymentMethod::Check.create!(active: true, name: 'Check1') }
  let(:payment_method3) { Spree::PaymentMethod::Check.create!(active: true, name: 'Check1') }

  describe 'loyalty_points_type' do

    it "should return PaymentMethod of LoyaltyPoints type" do
      expect(Spree::PaymentMethod.loyalty_points_type).to eq([loyalty_points_payment_method])
    end

  end

  describe "loyalty_points_id_included?" do

    context "when loyalty points id included in method ids" do

      it "should return true" do
        expect(Spree::PaymentMethod.loyalty_points_id_included?([loyalty_points_payment_method.id, payment_method2.id])).to be_truthy
      end

    end

    context "when loyalty points id not included in method ids" do

      it "should return false" do
        expect(Spree::PaymentMethod.loyalty_points_id_included?([payment_method2.id, payment_method3.id])).to be_falsey
      end

    end

  end

end