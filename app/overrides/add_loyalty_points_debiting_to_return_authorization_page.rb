Deface::Override.new(:virtual_path => 'spree/admin/return_authorizations/_form',
  :name => 'add_loyalty_points_debiting_to_return_authorization_page',
  :insert_before => "erb[loud]:contains('field_container :reason')",
  :text => "
  <% if !@order.payment_by_loyalty_points? && @order.eligible_for_loyalty_points?(@order.item_total) %>
    <%= f.field_container :loyalty_points do %>
      <%= label :loyalty_points, Spree.t(:loyalty_points_debit) %> <span class='required'>*</span><br />
      <% if @return_authorization.received? %>
        <%= @return_authorization.loyalty_points %> points Debited <br />
      <% else %>
        <%= f.text_field :loyalty_points, {:style => 'width:80px;'} %>
        <%= f.hidden_field :loyalty_points_transaction_type, { value: :Debit } %>
        <br /> User's Loyalty Points Balance: <%= @order.user.loyalty_points_balance %> <br /> Loyalty Points Credited for this Order: <%= @order.loyalty_points_for(@order.item_total) %>
      <% end %>
    <% end %>
  <% elsif @order.payment_by_loyalty_points? %>
    <%= f.field_container :loyalty_points do %>
      <br /><%= label :loyalty_points, Spree.t(:loyalty_points_credit) %> <span class='required'>*</span><br />
      <% if @return_authorization.received? %>
        <%= @return_authorization.loyalty_points %> points Credited <br />
      <% else %>
        <%= f.text_field :loyalty_points, {:style => 'width:80px;'} %>
        <%= f.hidden_field :loyalty_points_transaction_type, { value: :Credit } %>
        <br /> User's Loyalty Points Balance: <%= @order.user.loyalty_points_balance %> <br /> Loyalty Points Debited for this Order: <%= @order.loyalty_points_for(@order.total, 'redeem') %>
      <% end %>
    <% end %>
  <% end %>
  ")
