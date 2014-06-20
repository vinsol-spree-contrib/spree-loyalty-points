Deface::Override.new(:virtual_path => 'spree/admin/payments/_list',
  :name => 'add_loyalty_points_to_admin_order_payment_page_head',
  :insert_before => "tr[data-hook='payments_header'] th.actions",
  :text => "
    <% if payments.any_with_loyalty_points? -%>
      <th><%= Spree.t(:loyalty_points) %></th>
    <% end %>
  ")

Deface::Override.new(:virtual_path => 'spree/admin/payments/_list',
  :name => 'add_loyalty_points_to_admin_order_payment_page_row',
  :insert_before => "tr[data-hook='payments_row'] td.actions",
  :text => "
    <% if payments.any_with_loyalty_points? -%>
      <% if payment.by_loyalty_points? -%>
        <td><%= payment.loyalty_points_for(payment.amount, 'redeem') %> pts</td>
      <% else -%>
        <td>N.A.</td>
      <% end %>
    <% end %>
  ")

Deface::Override.new(:virtual_path => 'spree/admin/payments/_list',
  :name => 'add_loyalty_points_line_to_admin_order_payment_page',
  :insert_after => "table",
  :text => "
    <% if payments.any_with_loyalty_points? -%>
      <p>If you cancel the order, please refund loyalty points to the user manually <%= link_to 'here', admin_user_loyalty_points_path(@order.user) %></p>
    <% end %>
  ")
