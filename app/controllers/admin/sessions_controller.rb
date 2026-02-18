module Admin
  class SessionsController < BaseController
    layout "admin_login"

    skip_before_action :authenticate_admin!, only: [:new, :create]

    def new
    end

    def create
      if valid_credentials?
        session[:admin_authenticated] = true
        redirect_to admin_root_path, notice: "Signed in successfully."
      else
        flash.now[:alert] = "Invalid email or password."
        render :new, status: :unprocessable_content
      end
    end

    def destroy
      session[:admin_authenticated] = nil
      redirect_to new_admin_session_path, notice: "Signed out."
    end

    private

    def valid_credentials?
      admin_email = Rails.application.credentials.admin_email
      admin_password = Rails.application.credentials.admin_password

      return false unless admin_email && admin_password

      ActiveSupport::SecurityUtils.secure_compare(params[:email].to_s, admin_email) &&
        ActiveSupport::SecurityUtils.secure_compare(params[:password].to_s, admin_password)
    end
  end
end
