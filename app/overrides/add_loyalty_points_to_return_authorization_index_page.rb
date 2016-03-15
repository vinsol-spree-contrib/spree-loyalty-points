Deface::Override.new(virtual_path: 'spree/admin/return_authorizations/index',
  name: 'add_loyalty_points_to_return_authorization_index_page_head',
  insert_after: "thead[data-hook='rma_header'] th:contains('amount')",
  text: "
    <th><%= Spree.t(:loyalty_points) %></th>
  ")

Deface::Override.new(virtual_path: 'spree/admin/return_authorizations/index',
  name: 'add_loyalty_points_to_return_authorization_index_page_row',
  insert_after: "tr[data-hook='rma_row'] td:contains('display_amount')",
  text: "
    <td><%= return_authorization.loyalty_points %> pts <%= return_authorization.loyalty_points_transaction_type %></td>
  ")
