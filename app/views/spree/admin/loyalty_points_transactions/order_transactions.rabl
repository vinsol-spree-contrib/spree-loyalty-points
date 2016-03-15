collection(@loyalty_points_transactions)
attributes :source_type, :comment, :updated_at, :loyalty_points, :balance, :transaction_type
child source: :source do
  attributes :id, :number
end