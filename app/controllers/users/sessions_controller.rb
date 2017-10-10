# Overridden Devise::SessionsController
class Users::SessionsController < Devise::SessionsController

  # GET /resource/sign_in
  def new
    create
  end

  # POST /resource/sign_in
  def create
    if Rails.env.development?
      request.env['HTTP_REMOTE_USER'] = ENV['DEV_USER']
    end
    super
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  private


  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    # caught by apache to trigger pubcookie logout
    '/logout'
  end

end
