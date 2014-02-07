#TODO -> Use concern for loyaltypoint related logic in order model.

Spree::Order.class_eval do

  include Spree::Order::LoyaltyPoints

  has_many :loyalty_points_transactions, as: :source
  has_many :loyalty_points_credit_transactions, as: :source
  has_many :loyalty_points_debit_transactions, as: :source

  scope :loyalty_points_not_awarded, -> { includes(:loyalty_points_credit_transactions).where(:spree_loyalty_points_transactions => { :source_id => nil } ) }

  #TODO -> Redeem loyalty points before completing the order. Also, we can move this logic in before completing the correponding loyalty_point payment 

  fsm = self.state_machines[:state]
  fsm.before_transition :from => fsm.states.map(&:name) - [:complete], :to => [:complete], :do => :complete_loyalty_points_payments

end
