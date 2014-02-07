#TODO -> Use concern for loyaltypoint related logic in order model.

Spree::Order.class_eval do

  include Spree::Order::LoyaltyPoints

  has_many :loyalty_points_transactions, as: :source
  has_many :loyalty_points_credit_transactions, as: :source
  has_many :loyalty_points_debit_transactions, as: :source

  scope :loyalty_points_not_awarded, -> { includes(:loyalty_points_credit_transactions).where(:spree_loyalty_points_transactions => { :source_id => nil } ) }

  scope :with_hours_since_payment, ->(num) { where('`spree_orders`.`paid_at` < ? ', num.hours.ago).loyalty_points_not_awarded }

  scope :with_uncredited_loyalty_points, ->(num) { with_hours_since_payment(num).loyalty_points_not_awarded }

  #TODO -> Redeem loyalty points before completing the order. Also, we can move this logic in before completing the correponding loyalty_point payment 

  fsm = self.state_machines[:state]
  fsm.before_transition :from => fsm.states.map(&:name) - [:complete], :to => [:complete], :do => :complete_loyalty_points_payments

  #TODO -> create this method in payment model.
  #TODO -> Check whether loading of all payments required or not.

end
