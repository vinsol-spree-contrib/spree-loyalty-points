#TODO -> Rspecs missing
#TODO -> Add description of this rake task in README and also tell them to create a cron job for this.
namespace :spree do
  namespace :loyalty_points do
    desc "Credit loyalty points to pending users accounts"
    task :award => :environment do
      Spree::Order.credit_loyalty_points_to_user
    end
  end
end
