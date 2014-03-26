Spree::Payment.class_eval do

  include Spree::LoyaltyPoints
  include Spree::Payment::LoyaltyPoints

  validates :amount, numericality: { greater_than: 0 }, :if => :by_loyalty_points?
  scope :state_not, ->(s) { where('state != ?', s) }

  fsm = self.state_machines[:state]
  fsm.after_transition :from => fsm.states.map(&:name) - [:completed], :to => [:completed], :do => :notify_paid_order

  fsm.after_transition :from => fsm.states.map(&:name) - [:completed], :to => [:completed], :do => :redeem_loyalty_points, :if => :by_loyalty_points?
  fsm.after_transition :from => [:completed], :to => fsm.states.map(&:name) - [:completed] , :do => :return_loyalty_points, :if => :by_loyalty_points?

  private

    def invalidate_old_payments
      order.payments.with_state('checkout').where("id != ?", self.id).each do |payment|
        payment.invalidate!
      end unless by_loyalty_points?
    end

    def notify_paid_order
      if all_payments_completed?
        order.touch :paid_at
      end
    end

    def all_payments_completed?
      order.payments.state_not('invalid').all? { |payment| payment.completed? }
    end

end
