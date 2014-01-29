Deface::Override.new(:virtual_path => 'spree/orders/edit',
  :name => 'add_loyalty_points_to_cart_page',
  :insert_after => "#subtotal h5",
  :text => "
    <% if @order.loyalty_points_for(@order.item_total) > 0 %>
      <h5><%= Spree.t(:loyalty_points_earnable, :quantity => \"<span class='order-total'> \#{@order.loyalty_points_for(@order.item_total)}</span>\").html_safe %></h5>
    <% end %>
  ")