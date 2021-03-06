class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception

  # For JSON API, protect with null_session
  protect_from_forgery with: :null_session, if: proc { |c| c.request.format == 'application/json' }

  respond_to :html, :json
  before_filter :configure_permitted_parameters, if: :devise_controller?

protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :first_name << :last_name
    devise_parameter_sanitizer.for(:account_update) << :first_name << :last_name
  end

  def not_permitted
    { :json => {success: false, 
                error: "You don't have permission.",
                status:  "401"}, 
                :status => "401" }
  end

  def not_found
    { :json => {success: false,
                error: "Resource not found",
                status: "404"}, status: :not_found }
  end

  def authorize
    if !signed_in? && !authenticate_user_from_token
      case request.format
      when Mime::JSON
        render not_permitted and return
      else
        session[:return_to] = request.original_url
        redirect_to login_url
      end
    end
  end

  def authenticate_user_from_token
    token = token_from_params || token_from_headers
    user  = token && User.find_by_authentication_token(token.to_s)
 
    if user
      sign_in user
    end
  end

  def token_from_params
    params[:auth_token].presence
  end

  def token_from_headers
    if request.headers['Authorization'] and request.headers['Authorization'] =~ /auth_token\s+(.*)\s*/i
      $1
    end
  end
end
