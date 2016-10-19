Spree Loyalty Points [![Code Climate](https://codeclimate.com/github/vinsol/spree-loyalty-points.png)](https://codeclimate.com/github/vinsol/spree-loyalty-points) [![Build Status](https://travis-ci.org/vinsol/spree-loyalty-points.png?branch=master)](https://travis-ci.org/vinsol/spree-loyalty-points)
====================

Loyalty Points extension allows customers to earn loyalty points on the basis of their purchases. Admin can also reward Loyalty Points to it’s customers manually. Customer can use these loyalty points to pay for their future orders.

This extension allows admin to create a new payment method “Loyalty Points” in the system. Once this payment method is created and active, it would appear on checkout screen and customers can use this payment method for payments.

This extension also automates the awarding of loyalty points to customers based on the configuration done by admin and updating loyalty points based on the transactions on Spree Commerce platform.

This extension allows only Loyalty Points payment method for making a purchase and does not allow the payment through other payment modes like cash, check, credit card etc.

Installation
------------

In your `Gemfile`, add:

```ruby
gem 'spree_loyalty_points', github: 'vinsol-spree-contrib/spree-loyalty-points', branch: '3-0-stable'
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g spree_loyalty_points:install
```

How it works
-----

* To add loyalty point feature, Spree admin needs to create “Loyalty Points” payment method

    Configuration -> Payment Methods -> New payment Method

    You need to select “Spree::PaymentMethod::LoyaltyPoints” as a Provider

* Spree admin need to make following settings on Configuration page:

   - **Set minimum amount of an order that should be spent by the customer to earn loyalty points** - On the basis of this, it will be decided by the system whether loyalty points should be awarded for the order or not, based on the order value.

  - **Set number of loyalty points to be awarded per unit amount spent** - On the    basis of this configuration, number of loyalty points to be awarded are calculated based on the order  value and per unit value defined. The loyalty points get added to the customer’s account which he can use in future purchases.

    Ex. Suppose Admin set this value this value to 1, it means, Customer will receive 1 Loyalty Point on spending every $1 on this site.

       In order to receive loyalty points the payment should be done through some other
     mode like Credit card, Debit card, Cash, Check etc.

     No loyalty points are awarded for purchase done through existing Loyalty point
    balance

  - **Set minimum loyalty points balance required for redeeming** - On the basis of this, Customer will be permitted to make a payment with Loyalty Points only if he/she has Loyalty Points balance more than the minimum loyalty points set by the Admin.

  - **Set Loyalty Point to Amount conversion rate** - This conversion rate converts the loyalty points into amount. This amount is displayed on the checkout screen with Loyalty Points balance.

  - **Set Time to award Loyalty Points after payment** - Loyalty Points will be credited to the Customer’s account on the basis of  this set time period. This time period will be considered only after Customer makes the payment and Admin marks this payment “Capture”.

    **This field is provided to curb the misuse of the Loyalty Points by the customers. So, we suggest  to set this time on the basis of the merchant’s “Return Policy”.**

   ![lp settings](http://vinsol.com/gems_screenshots/spree-loyalty-points/lp%20settings.png)

* Admin can view list of the loyalty point transactions by following below mentioned steps:

  -  Go to Users Tab.
  - Select the user account.
  - Click on the Loyalty points Balance value.
   ![lp transactions](http://vinsol.com/gems_screenshots/spree-loyalty-points/lp%20transactions.png)

* Admin can also credit/debit loyalty points to the customers manually, by following below mentioned steps:

  - Go to Users tab
  - Select the User
  - Click on Loyalty Points Balance value
  - Click on “Update loyalty Points” to Credit/Debit Loyalty points.
   ![Credit LP](http://vinsol.com/gems_screenshots/spree-loyalty-points/credit%20lp.png)

* After setting mentioned configurations, Customer will be able to see this payment method on Checkout Page and can view details later on order detail page.

  - Loyalty Points and their respective money value at the time of checkout

   ![LP Checkout](http://vinsol.com/gems_screenshots/spree-loyalty-points/checkout.png)

  - His loyalty points transactions and order details.

   ![My Orders1](http://vinsol.com/gems_screenshots/spree-loyalty-points/lp%20myorders1.png)

   ![My Orders2](http://vinsol.com/gems_screenshots/spree-loyalty-points/lp%20myorders2.png)

* **View my points**:If a user wants to view his Loyalty Points balance he can go to “My Account” page.
* **Changing system currency**:Loyalty Points can be set only for one operating currency at any time. If Admin wants to change currency for the App, he/she needs to reset Loyalty Points Settings by considering that currency.
* **Cancelling order**:If Admin wants to “Cancel” order, He/She needs to “Credit” Loyalty Points manually into the User’s account by following below mentioned steps:

  - Go to Users tab
  - Select the User
  - Click on Loyalty Points Balance value
  - Select “Transaction Type” “Credit” from drop down
  - Select respective “Order number” from “Order” drop down
  - Click on “Update Loyalty Points”

   ![Credit LP](http://vinsol.com/gems_screenshots/spree-loyalty-points/credit%20lp.png)

* **Return Authorization**: In case a user returns the shipped order by contacting Customer Care then to return the LP associated with the order admin needs to create a “New Return Authorization” and mention LP to be credited into User’s account.

    Order’s Page -> Order Details Page -> Return Authorization -> New Return Authorization

   ![Return Authorization](http://vinsol.com/gems_screenshots/spree-loyalty-points/return%20authorization.png)

   After receiving the shipped product(s), Admin needs to “Receive” the Product. Once received,LP will be automatically     credited into User’s account.

      Order’s Page -> Order Details Page -> Return Authorization -> “Edit” Return Authorization -> Receive

   ![Receive1](http://vinsol.com/gems_screenshots/spree-loyalty-points/receive1.png)

   ![Receive](http://vinsol.com/gems_screenshots/spree-loyalty-points/receive.png)

Update Loyalty Points in the system
-----

Loyalty Points will be awarded to the customer only after:
   - Admin captures the payment manually for his order
   - “Time” set in Loyalty Point configuration has elapsed after capturing the payment.

Add a Cron Job to run the following rake task to award Loyalty Points to customers who satisfy the above two conditions.

```shell
bundle exec rake spree:loyalty_points:award
```



Contributing
------------

1. Fork the repo.
2. Clone your repo.
3. Run `bundle install`.
4. Run `bundle exec rake test_app` to create the test application in `spec/test_app`.
5. Make your changes.
6. Ensure specs pass by running `bundle exec rspec spec`.
7. Submit your pull request.

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

```shell
bundle
bundle exec rake test_app
bundle exec rspec spec
```

Credits
-------

[![vinsol.com: Ruby on Rails, iOS and Android developers](http://vinsol.com/vin_logo.png "Ruby on Rails, iOS and Android developers")](http://vinsol.com)

Copyright (c) 2016 [vinsol.com](http://vinsol.com "Ruby on Rails, iOS and Android developers"), released under the New MIT License
