Spree::Payment.class_eval do

  validates :amount, numericality: { greater_than: 0 }, :if => :by_loyalty_points?
  scope :state_not, ->(s) { where('state != ?', s) }

  fsm = self.state_machines[:state]
  fsm.after_transition :from => fsm.states.map(&:name) - [:completed], :to => [:completed], :do => :notify_paid_order

  #TODO -> Use payment's amount instead of order's total
  
  fsm.after_transition :from => fsm.states.map(&:name) - [:completed], :to => [:completed], :do => :redeem_loyalty_points, :if => :by_loyalty_points?
  fsm.after_transition :from => [:completed], :to => fsm.states.map(&:name) - [:completed] , :do => :return_loyalty_points, :if => :by_loyalty_points?

  def self.any_with_loyalty_points?
    by_loyalty_points.size != 0
  end

  #TODO -> Why eager load payment methods ?
  def self.by_loyalty_points
    joins(:payment_method).where(:spree_payment_methods => { type: 'Spree::PaymentMethod::LoyaltyPoints'})
  end

  def invalidate_old_payments
    order.payments.with_state('checkout').where("id != ?", self.id).each do |payment|
      payment.invalidate!
    end unless by_loyalty_points?
  end

  private

    def notify_paid_order
      if all_payments_completed?
        order.touch :paid_at
      end
    end

    def by_loyalty_points?
      payment_method.type == "Spree::PaymentMethod::LoyaltyPoints"
    end

    def all_payments_completed?
      order.payments.state_not('invalid').all? { |payment| payment.completed? }
    end

    def return_loyalty_points
      order.return_loyalty_points(amount)
    end

    def redeem_loyalty_points
      order.redeem_loyalty_points()
    end

end
