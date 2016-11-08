Deface::Override.new(virtual_path: 'spree/shared/_order_details',
  name: 'add_loyalty_points_to_order_checkout_page',
  insert_after: "#order-charges",
  text: "
    <tfoot id='loyalty_points'>
      <tr id='loyalty-points-row'>
        <% if @order.loyalty_points_awarded? %>
          <td></td>
          <td colspan='4' class='total'><span><%= @order.loyalty_points_for(@order.item_total) %></span> <b><%= Spree.t(:loyalty_points_have_been_credited) %></b></td>
        <% else %>
          <td></td>
          <td colspan='4' class='total'><span><%= @order.loyalty_points_for(@order.item_total) %></span> <b><%= Spree.t(:loyalty_points_will_be_credited) %></b></td>
        <% end %>
      </tr>
    </tfoot>
  ")
