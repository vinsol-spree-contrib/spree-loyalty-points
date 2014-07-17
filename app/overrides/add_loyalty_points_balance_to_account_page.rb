Deface::Override.new(:virtual_path => 'spree/users/show',
  :name => 'add_loyalty_points_balance_to_account_page',
  :insert_after => "#user-info",
  :text => "
    <% if Spree::PaymentMethod::LoyaltyPoints.active? %>
      <dl id='loyalty-points-info'>
        <dt><%= Spree.t(:loyalty_points_balance) %></dt>
        <dd><%= @user.loyalty_points_balance %> (<%= link_to Spree.t(:details), spree.loyalty_points_path %>)</dd>
      </dl>
    <% end %>
  ")