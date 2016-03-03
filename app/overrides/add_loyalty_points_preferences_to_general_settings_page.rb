Deface::Override.new(virtual_path: 'spree/admin/general_settings/edit',
  name: 'add_loyalty_points_preferences_to_general_settings_page',
  insert_before: "div.form-actions",
  text: "
    <div class='row'>
      <fieldset class='loyalty-points no-border-bottom'>
        <legend align='center'><%= Spree.t(:loyalty_points_settings)%></legend>
        <% @preferences_loyalty_points.each do |key, value|
            type = Spree::Config.preference_type(key) %>
            <div class='field'>
              <%= label_tag(key, Spree.t(key)) + tag(:br) if type != :boolean %>
              <%= preference_field_tag(key, Spree::Config[key], type: type) %>
              <p><%= value[0] %></p>
            </div>
        <% end %>
      </fieldset>
    </div>
  ")