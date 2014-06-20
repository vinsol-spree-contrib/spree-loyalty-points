Deface::Override.new(:virtual_path => 'spree/checkout/_payment',
  :name => 'add_loyalty_points_balance_to_checkout_payment_page',
  :insert_before => "div[data-hook='checkout_payment_step']",
  :text => "
    <div id='loyalty_points_info'>You can earn Loyalty Points for this order if paid by some other method except Loyalty Points</div>
  ")
