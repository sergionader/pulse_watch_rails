class SessionsController < ApplicationController
  def new
    redirect_to admin_monitors_path if current_user
  end

  def create
    user = User.find_by("LOWER(email) = ?", params[:email].to_s.downcase)

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to admin_monitors_path, notice: "Signed in successfully."
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to login_path, notice: "Signed out."
  end
end
