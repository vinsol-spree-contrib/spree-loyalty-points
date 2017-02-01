require 'spec_helper'

describe Spree::Admin::ReturnAuthorizationsController, type: :controller do

  let(:order) { mock_model(Spree::Order).as_null_object }
  let(:return_authorization) { mock_model(Spree::ReturnAuthorization).as_null_object }
  let(:user) { return_authorization.order.user }

  before :each do
    allow(controller).to receive(:load_resource_instance).and_return(return_authorization)
    allow(controller).to receive(:spree_current_user).and_return(user)
    allow(controller).to receive(:authorize!).and_return(true)
    allow(controller).to receive(:authorize_admin).and_return(true)
  end

  describe "set_loyalty_points_transactions callback" do

    it "should be included in before action callbacks" do
      expect(Spree::Admin::ReturnAuthorizationsController._process_action_callbacks.select{ |callback| callback.kind == :before }.map(&:filter).include?(:set_loyalty_points_transactions)).to be_truthy
    end

  end

  describe "set_loyalty_points_transactions" do

      let(:loyalty_points_transactions) { return_authorization.order.loyalty_points_transactions }
    before :each do
      allow(return_authorization.order).to receive(:loyalty_points_transactions).and_return(loyalty_points_transactions)
      allow(loyalty_points_transactions).to receive(:page).and_return(loyalty_points_transactions)
      allow(loyalty_points_transactions).to receive(:per).and_return(loyalty_points_transactions)
    end

    def send_request(params = {})
      get :new, params: params.merge!(order_id: order.id)
    end

    context 'with successful response' do
      before { send_request }

      it "assigns loyalty_points_transactions" do
        expect(assigns[:loyalty_points_transactions]).to_not be_nil
      end

      it "renders new template" do
        expect(response).to render_template(:new)
      end
    end

    context 'with correct method flow' do
      it "user should receive loyalty_points_transactions" do
        expect(user).to receive(:loyalty_points_transactions)
      end

      after { send_request }
    end

    it "assigns loyalty_points_transactions" do
      send_request
      expect(assigns[:loyalty_points_transactions]).to eq(loyalty_points_transactions)
    end

    it "should receive loyalty_points_transactions on order" do
      expect(return_authorization.order).to receive(:loyalty_points_transactions)
      send_request
    end

    it "should receive page on loyalty_points_transactions" do
      expect(loyalty_points_transactions).to receive(:page).with('2')
      send_request(page: 2)
    end

    context "when per_page is passed as a parameter" do

      it "should receive per with per_page on loyalty_points_transactions" do
        expect(loyalty_points_transactions).to receive(:per).with('20')
        send_request(per_page: 20)
      end

    end

    context "when per_page is not passed as a parameter" do

      it "should receive per with Spree::Config[:admin_orders_per_page] on loyalty_points_transactions" do
        expect(loyalty_points_transactions).to receive(:per).with(Spree::Config[:admin_orders_per_page])
        send_request
      end

    end

  end

end
