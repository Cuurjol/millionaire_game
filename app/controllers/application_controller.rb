class ApplicationController < ActionController::Base
  before_action :configure_devise_params, if: :devise_controller?
  before_action :set_new_game
  before_action :set_locale

  def configure_devise_params
    devise_parameter_sanitizer.permit(:sign_up) do |user|
      user.permit(:name, :email, :password, :password_confirmation)
    end

    devise_parameter_sanitizer.permit(:account_update) do |user|
      user.permit(:name, :password, :password_confirmation, :current_password)
    end
  end

  def set_locale
    I18n.locale = [RailsAdmin].include?(self.class.parent) ? :en : I18n.default_locale
  end

  def set_new_game
    @new_game ||= Game.new
  end
end
