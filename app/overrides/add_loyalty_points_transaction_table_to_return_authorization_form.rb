Deface::Override.new(virtual_path: 'spree/admin/return_authorizations/_form',
  name: 'add_loyalty_points_transaction_table_to_return_authorization_form',
  insert_after: "div[data-hook='admin_return_authorization_form_fields']",
  text: "
    <%= render partial: 'spree/loyalty_points/transaction_table' %>
  ")
