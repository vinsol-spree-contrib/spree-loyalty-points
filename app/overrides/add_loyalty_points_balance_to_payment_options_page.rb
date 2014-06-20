Deface::Override.new(:virtual_path => 'spree/checkout/_payment',
  :name => 'add_loyalty_points_balance_to_payment_option_page',
  :insert_after => "div[data-hook='checkout_payment_step'] p label",
  :text => "
    <%- if method.name == 'Loyalty Points' %>
      <%- lp_balance = spree_current_user.loyalty_points_balance %>
      <%- equivalent_currency_balance = spree_current_user.loyalty_points_equivalent_currency %>
      <br/><span class='small loyalty_points_details balance'>Loyalty Points Balance: <%= lp_balance %><%= '(Equivalent to $' + equivalent_currency_balance.to_s + ')' %></span>
      <%- lp_needed = @order.loyalty_points_for(@order.total, 'redeem') %>
      <%- lp_needed_equivalent_currency = lp_needed  * Spree::Config.loyalty_points_conversion_rate %>
      <br/><span class='small loyalty_points_details needed'>Loyalty Points Needed: <%= lp_needed %><%= '(Equivalent to $' + lp_needed_equivalent_currency.to_s + ')' %></span>
    <%- end %>
  ")
