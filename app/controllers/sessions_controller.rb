class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by("LOWER(email) = ?", params[:email].to_s.downcase)
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to "/users", notice: "Logged in successfully."
    else
      flash.now[:alert] = "Invalid email or password."
      render :new
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Logged out successfully."
  end
end
