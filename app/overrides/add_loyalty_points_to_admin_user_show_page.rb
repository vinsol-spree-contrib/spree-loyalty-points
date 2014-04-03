Deface::Override.new(:virtual_path => 'spree/admin/users/show',
  :name => 'add_loyalty_points_to_admin_user_show_page',
  :insert_after => "tr[data-hook='roles']",
  :text => "
  <tr data-hook='loyalty-points'>
    <th><%= Spree.t(:loyalty_points_balance) %></th>
    <td>
      <% if @user.loyalty_points_balance.present? %>
        <%= link_to Spree::LoyaltyPoints.loyalty_points_format.display(@user, @user.loyalty_points_balance), spree.admin_user_loyalty_points_path(@user) %>
      <% else %>
        <%= 'No loyalty points yet' %>
      <% end %>
    </td>
  </tr>
  ")
