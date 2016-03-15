require 'spec_helper'

describe Spree::LoyaltyPointsController, type: :controller do

  let(:user) { mock_model(Spree.user_class).as_null_object }

  before(:each) do
    allow(controller).to receive(:spree_current_user).and_return(user)
    allow(user).to receive(:generate_spree_api_key!).and_return(true)
    allow(controller).to receive(:authorize!).and_return(true)
  end

  describe "GET 'index'" do
    def send_request(params = {})
      get :index, params
    end

    let(:loyalty_points_transactions) { user.loyalty_points_transactions }
    before :each do
      allow(loyalty_points_transactions).to receive(:includes).and_return(loyalty_points_transactions)
      allow(loyalty_points_transactions).to receive(:order).and_return(loyalty_points_transactions)
      allow(loyalty_points_transactions).to receive(:page).and_return(loyalty_points_transactions)
      allow(loyalty_points_transactions).to receive(:per).and_return(loyalty_points_transactions)
    end

    it "should receive loyalty_points_transactions on spree_current_user" do
      expect(user).to receive(:loyalty_points_transactions).and_return(loyalty_points_transactions)
      send_request
    end

    it "assigns loyalty_points_transactions" do
      send_request
      expect(assigns[:loyalty_points_transactions]).to eq(loyalty_points_transactions)
    end

    it "renders index template" do
      send_request
      expect(response).to render_template(:index)
    end

    it "should receive includes on loyalty_points_transactions" do
      expect(loyalty_points_transactions).to receive(:includes).with(:source)
      send_request
    end

    it "should receive order on loyalty_points_transactions" do
      expect(loyalty_points_transactions).to receive(:order).with(updated_at: :desc)
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

      it "should receive per with Spree::Config[:orders_per_page] on loyalty_points_transactions" do
        expect(loyalty_points_transactions).to receive(:per).with(Spree::Config[:orders_per_page])
        send_request
      end

    end

  end

end
