Deface::Override.new(:virtual_path => 'spree/admin/return_authorizations/_form',
  :name => 'add_loyalty_points_to_new_return_authorization_page_head',
  :insert_bottom => "tr[data-hook='rma_header']",
  :text => "
    <th><%= Spree.t(:loyalty_points) %></th>
  ")

Deface::Override.new(:virtual_path => 'spree/admin/return_authorizations/_form',
  :name => 'add_loyalty_points_to_new_return_authorization_page_row',
  :insert_bottom => "tr[data-hook='rma_row']",
  :text => "
    <% if @order.loyalty_points_transactions.where(transaction_type: 'Debit').present? %>
      <td><%= @order.loyalty_points_for(@order.total, 'redeem') %></td>
    <% else %>
      <td>0</td>
    <% end %>
  ")
