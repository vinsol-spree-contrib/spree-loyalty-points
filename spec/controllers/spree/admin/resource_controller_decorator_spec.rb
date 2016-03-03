require 'spec_helper'

describe Spree::Admin::ResourceController, type: :controller do

  describe "parent" do
    context "when parent_data is present" do

      before :each do
        controller.stub(:parent_data).and_return({ model_name: 'spree/order', model_class: Spree::Order, find_by: 'id' })
      end

      context "when @parent is present" do

        before :each do
          order = create(:order_with_loyalty_points)
          controller.stub(:params).and_return({ "order_id" =>  order.id.to_s })
          Spree::Order.stub(:find_by_id).and_return(order)
        end

        it "assigns parent" do
          controller.send(:parent)
          assigns[:parent].should_not be_nil
        end

      end

      context "when @parent is absent" do

        before :each do
          controller.stub(:params).and_return({ "order_id" =>  "0" })
        end

        it "should raise ActiveRecord::RecordNotFound error" do
          expect {
            controller.send(:parent)
            }.to raise_error(ActiveRecord::RecordNotFound)
        end

      end

    end
    
    context "when parent_data is absent" do

      before :each do
        controller.stub(:parent_data).and_return({})
      end

      it "should return nil" do
        controller.send(:parent).should be_nil
      end

    end

  end

end