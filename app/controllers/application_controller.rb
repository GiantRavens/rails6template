class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  # override the devise signin and signout url behavior
  def after_sign_in_path_for(_resource_or_scope)
    welcome_url
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_url
  end

  protected

  # Allow extra attributes for user signup and user profile edit
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(:firstname, :lastname, :email, :password, :current_password, :isadmin)
    end

    devise_parameter_sanitizer.permit(:account_update) do |u|
      u.permit(:firstname, :lastname, :email, :password, :password_confirmation,
               :current_password, :isadmin)
    end
  end
end
