Spree::Admin::GeneralSettingsController.class_eval do

  before_action :set_loyalty_points_settings, only: [:edit]

  private

    def set_loyalty_points_settings
      @preferences_loyalty_points = {
        :min_amount_required_to_get_loyalty_points => [""],
        :loyalty_points_awarding_unit => ["For example: Set this as 10 if we wish to award 10 points for $1 spent on the site."],
        :loyalty_points_redeeming_balance => [""],
        :loyalty_points_conversion_rate => ["For example: Set this value to 5 if we wish 1 loyalty point is equivalent to $5"],
        :loyalty_points_award_period => [""]
      }
    end

end