Deface::Override.new(:virtual_path => 'spree/admin/return_authorizations/_form',
  :name => 'surround_amount_with_condition_in_return_authorization_form',
  :surround => "erb[loud]:contains('field_container :amount')",
  :text => "
    <% if !@return_authorization.order.payment_by_loyalty_points? %>
      <%= render_original %>
    <% end %>
  ")
