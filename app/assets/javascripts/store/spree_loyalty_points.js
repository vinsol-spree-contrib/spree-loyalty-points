//= require store/spree_frontend

$(document).ready(function() {
  var $loyalty_points_details = $('.small.loyalty_points_details');
  var $loyalty_points_radio_label = $loyalty_points_details.parents("p").children("label");
  $loyalty_points_radio_label.on("click", function() {
    var $loyalty_points_details = $('.small.loyalty_points_details');
    $loyalty_points_details.hide();
  });
  var $radio_button_labels = $("div[data-hook='checkout_payment_step'] label");
  $radio_button_labels.not($loyalty_points_radio_label).on("click", function() {
    var $loyalty_points_details = $('.small.loyalty_points_details');
    $loyalty_points_details.show();
  });
});