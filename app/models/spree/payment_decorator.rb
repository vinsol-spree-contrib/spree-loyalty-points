Spree::Payment.class_eval do

  scope :state_not, ->(s) { where('state != ?', s) }

  def notify_paid_order
    if all_payments_completed?
      order.touch :paid_at
    end
  end

  def all_payments_completed?
    order.payments.state_not('invalid').all? { |payment| payment.completed? }
  end

end

Spree::Payment.state_machine.after_transition :to => :completed, :do => :notify_paid_order
