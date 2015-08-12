class SessionsController < Devise::SessionsController

  skip_before_filter :verify_authenticity_token

    def require_no_authentication
        assert_is_devise_resource!
        return unless is_navigational_format?
        no_input = devise_mapping.no_input_strategies

        authenticated = if no_input.present?
          args = no_input.dup.push :scope => resource_name
          warden.authenticate?(*args)
        else
          warden.authenticated?(resource_name)
        end

        if authenticated && resource = warden.user(resource_name)
          user = User.find(resource.id)
          respond_to do | format |
            format.json { render :json => {:user => user.as_json }, :status => 200 }
          end
        end
    end

  def create

    params[:user] ||= {:email => params[:email],:password => params[:password]}

    resource = warden.authenticate!(:scope => resource_name, :recall => "sessions#failure")
    sign_in(resource_name, resource)

    respond_to do | format |
      user = User.find(resource.id)
      format.json { render :json => { :success => true, :user => user.as_json }, :status => 200 }
    end

  end

  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message :notice, :signed_out if signed_out && is_navigational_format?

    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.json { render :json => { :success => true}, :status => 200 } if signed_out && is_navigational_format?
    end
  end

  def new

    logger.debug "Is user signed in? "+user_signed_in?.to_json+"\n\n\n"
    if user_signed_in? == true
      respond_to do | format |
        user = User.find(resource.id)
        format.json { render :json => {:user => user.as_json }, :status => 200 }
      end
    else
      self.resource = build_resource(nil, :unsafe => true)
      clean_up_passwords(resource)
      respond_with(resource, serialize_options(User.new))
    end
  end

  def failure
    return render :status=>401, :json => {:success => false, :errors => flash}
  end

end