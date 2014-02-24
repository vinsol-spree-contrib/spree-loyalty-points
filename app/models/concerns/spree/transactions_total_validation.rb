require 'active_support/concern'

module Spree
  module TransactionsTotalValidation
    extend ActiveSupport::Concern

      def net_transactions_sum(trans_type, relation)
        credit_transactions_total = relation.loyalty_points_credit_transactions.sum(:loyalty_points)
        debit_transactions_total = relation.loyalty_points_debit_transactions.sum(:loyalty_points)
        trans_type == "Debit" ? debit_transactions_total += loyalty_points : credit_transactions_total += loyalty_points
        credit_transactions_total - debit_transactions_total
      end

      def validate_transactions_total_range(trans_type, relation)
        net_transactions_total = net_transactions_sum(trans_type, relation)
        first_transaction = relation.loyalty_points_transactions.first
        if first_transaction.transaction_type == "Debit"
          errors.add :base, "Loyalty Points Net Debit Total should be in the range [0, #{ first_transaction.loyalty_points }]" if net_transactions_total > 0 || net_transactions_total < -first_transaction.loyalty_points
        else
          errors.add :base, "Loyalty Points Net Credit Total should be in the range [0, #{ first_transaction.loyalty_points }]" if net_transactions_total < 0 || net_transactions_total > first_transaction.loyalty_points
        end
      end

  end
end