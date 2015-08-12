class RegistrationsController < Devise::RegistrationsController
    def create
      #hack :P
      params[:user] ||= {:email => params[:email],:password => params[:password],:password_confirmation => params[:password_confirmation]}

        build_resource

        if resource.save
          if resource.active_for_authentication?
            sign_up(resource_name, resource)
            return render :json => {:success => true, "message"=> resource.to_json}
          else
            expire_session_data_after_sign_in!
            return render :json => {:success => true, "message" => :"signed_up_but_#{resource.inactive_message}"}
          end
        else
          clean_up_passwords resource
          return render :json => {:success => false, "error" => resource.errors.full_messages}
        end
    end

    def sign_up(resource_name, resource)
        sign_in(resource_name, resource)
    end
end