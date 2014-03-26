Spree Loyalty Points [![Code Climate](https://codeclimate.com/github/vinsol/spree-loyalty-points.png)](https://codeclimate.com/github/vinsol/spree-loyalty-points) [![Build Status](https://travis-ci.org/vinsol/spree-loyalty-points.png?branch=master)](https://travis-ci.org/vinsol/spree-loyalty-points)
====================

This extension adds Loyalty Points for users.


Installation
------------

Add spree_loyalty_points to your Gemfile:

```ruby
gem 'spree_loyalty_points', '~> 1.0.2'
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g spree_loyalty_points:install
```

Usage
-----

From Admin end, create a payment method of LoyaltyPoints type for payment with Loyalty Points.

Go to the Admin end of the website and open the Configurations Tab. Set up the values for the following Loyalty Points Settings under General Settings:

* Minimum Amount to be spent per Order(Item Total, excluding Shipping and any other Charges) to award Loyalty Points : This is the minimum amount the user has to spend on an order to receive Loyalty Points for that order
* Number of Loyalty Points to be awarded per Unit Amount Spent : Loyalty Points to be awarded against Unit Amount spent on Order
* Minimum Loyalty Points Balance Required for Redeeming : Minimum Loyalty Points Balance a user should have for spending Loyalty Points
* Loyalty Point to Amount Conversion Rate : Conversion Rate for getting Amount equivalent value of Loyalty Points
* Time(in hours) after payment to award Loyalty Points : Time period to wait from the time payment is received for the order to award Loyalty Points

After an order's payment is received, Loyalty Points will be awarded (only after the Time period specified in the above setting) when you run the rake task.
Add a Cron Job to run the following Rake Task to Award Loyalty Points to Users:

```shell
bundle exec rake spree:loyalty_points:award
```

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

```shell
bundle
bundle exec rake test_app
bundle exec rspec spec
```

When testing your applications integration with this extension you may use it's factories.
Simply add this require statement to your spec_helper:

```ruby
require 'spree_loyalty_points/factories'
```


Credits
-------

[![vinsol.com: Ruby on Rails, iOS and Android developers](http://vinsol.com/vin_logo.png "Ruby on Rails, iOS and Android developers")](http://vinsol.com)

Copyright (c) 2014 [vinsol.com](http://vinsol.com "Ruby on Rails, iOS and Android developers"), released under the New MIT License
