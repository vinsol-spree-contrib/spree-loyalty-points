Deface::Override.new(
  virtual_path: 'spree/admin/products/_form',
  name: "add_eligible_flag_to_products",
  insert_bottom: "[data-hook='admin_product_form_fields']",
  partial: "spree/admin/products/loyalty_points_eligible_flag"
)
