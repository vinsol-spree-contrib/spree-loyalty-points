Spree::Admin::ResourceController.class_eval do

  protected

    def parent
      if parent_data.is_a?(Hash) &&  (parent_data[:model_class]).present?
        @parent ||= parent_data[:model_class].send("find_by_#{ parent_data[:find_by] }", params["#{ resource.model_name }_id"])
        raise ActiveRecord::RecordNotFound unless @parent
        instance_variable_set("@#{ resource.model_name }", @parent)
      else
        nil
      end
    end

    def resource_not_found
      flash[:error] = flash_message_for(model_class.new, :not_found)
      flash[:error] = flash_message_for(parent_data[:model_class].new, :not_found) if parent_data.present? && @parent.nil?
      redirect_to collection_url
    end

end
