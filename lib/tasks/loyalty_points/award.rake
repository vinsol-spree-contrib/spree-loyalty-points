namespace :spree do
  namespace :loyalty_points do
    desc "Credit loyalty points to pending users accounts"
    task :award => :environment do
      points_award_period = Spree::Config.loyalty_points_award_period
      orders = Spree::Order.where('`spree_orders`.`paid_at` < ? ', points_award_period.days.ago).where(loyalty_points_awarded: false)
      orders.each do |order|
        order.add_loyalty_points
        order.mark_awarded
      end
    end
  end
end
