Deface::Override.new(:virtual_path => 'spree/admin/return_authorizations/_form',
  :name => 'add_loyalty_points_to_return_authorization_page',
  :insert_before => "erb[loud]:contains('field_container :reason')",
  :text => "
  <% if !@order.loyalty_points_used? && @order.eligible_for_loyalty_points?(@order.loyalty_points_eligible_total) %>
    <%= f.field_container :loyalty_points do %>
      <%= label :loyalty_points, Spree.t(:loyalty_points_debit) %> <span class='required'>*</span><br />
      <% if @return_authorization.received? %>
        <%= @return_authorization.loyalty_points %> points Debited <br />
      <% else %>
        <%= f.text_field :loyalty_points, {:style => 'width:80px;'} %>
        <%= f.hidden_field :loyalty_points_transaction_type, { value: :Debit } %>
        <br /> User's Loyalty Points Balance: <%= @order.user.loyalty_points_balance %> <br /> Net Loyalty Points Credited for this Order: <%= @order.loyalty_points_total %>
      <% end %>
    <% end %>
  <% elsif @order.loyalty_points_used? %>
    <%= f.field_container :loyalty_points do %>
      <br /><%= label :loyalty_points, Spree.t(:loyalty_points_credit) %> <span class='required'>*</span><br />
      <% if @return_authorization.received? %>
        <%= @return_authorization.loyalty_points %> points Credited <br />
      <% else %>
        <%= f.text_field :loyalty_points, {:style => 'width:80px;'} %>
        <%= f.hidden_field :loyalty_points_transaction_type, { value: :Credit } %>
        <br /> User's Loyalty Points Balance: <%= @order.user.loyalty_points_balance %> <br /> Net Loyalty Points Debited for this Order: <%= -@order.loyalty_points_total %>
      <% end %>
    <% end %>
  <% end %>
  ")
