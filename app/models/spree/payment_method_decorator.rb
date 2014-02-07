Spree::PaymentMethod.class_eval do

  def self.loyalty_points_id_included?(method_ids)
    where(type: 'Spree::PaymentMethod::LoyaltyPoints').where(id: method_ids).size != 0
  end

end