FactoryGirl.define do
  # Define your Spree extensions Factories within this file to enable applications, and other extensions to use and override them.
  #
  # Example adding this to your spec_helper will load these Factories for use:
  # require 'spree_loyalty_points/factories'

  factory :loyalty_points_transaction, class: Spree::LoyaltyPointsTransaction do
    loyalty_points { (10..99).to_a.sample }
    balance { (100..999).to_a.sample }
    comment { Faker::Lorem.words(3).join(' ') }
    type "Spree::LoyaltyPointsCreditTransaction"

    association :user, factory: :user_with_loyalty_points

    factory :loyalty_points_credit_transaction, class: Spree::LoyaltyPointsCreditTransaction do
      type "Spree::LoyaltyPointsCreditTransaction"
    end

    factory :loyalty_points_debit_transaction, class: Spree::LoyaltyPointsDebitTransaction do
      type "Spree::LoyaltyPointsDebitTransaction"
    end

  end

  factory :user_with_loyalty_points, parent: :user do
    loyalty_points_balance { (100..999).to_a.sample }

    transient do
      transactions_count 5
    end

    after(:create) do |user, evaluator|
      create_list(:loyalty_points_transaction, evaluator.transactions_count, user: user)
    end
  end

  factory :order_with_loyalty_points, parent: :order do

    association :user, factory: :user_with_loyalty_points

    transient do
      transactions_count 5
    end

    after(:create) do |order, evaluator|
      create_list(:loyalty_points_transaction, evaluator.transactions_count, source: order)
    end

  factory :shipped_order_with_loyalty_points, parent: :shipped_order do
      transient do
        shipments_count 5
      end

      after(:create) do |order, evaluator|
        create_list(:shipment, evaluator.shipments_count, order: order, state: "shipped")
      end
    end

  end

  factory :payment_with_loyalty_points, parent: :payment do

    association :order, factory: :order_with_loyalty_points

  end

  factory :return_authorization_with_loyalty_points, parent: :return_authorization do
    loyalty_points { (50..99).to_a.sample }
    loyalty_points_transaction_type "Debit"

    association :order, factory: :shipped_order_with_loyalty_points

  end

end

FactoryGirl.modify do

  factory :return_authorization, class: Spree::ReturnAuthorization do
    loyalty_points { (50..99).to_a.sample }
    loyalty_points_transaction_type "Debit"
  end

end
