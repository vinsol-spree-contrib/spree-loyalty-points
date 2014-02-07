#TODO -> Rspecs missing
#TODO -> Add description of this rake task in README and also tell them to create a cron job for this.
namespace :spree do
  namespace :loyalty_points do
    desc "Credit loyalty points to pending users accounts"
    task :award => :environment do
      #TODO -> Move this logic into order model method in a concern.
      points_award_period = Spree::Config.loyalty_points_award_period
      #TODO -> create scope in order model.
      orders = Spree::Order.where('`spree_orders`.`paid_at` < ? ', points_award_period.hours.ago).loyalty_points_not_awarded
      orders.each do |order|
        order.add_loyalty_points
      end
    end
  end
end
