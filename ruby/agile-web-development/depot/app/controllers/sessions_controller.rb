class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

  def create
    user = User.count.zero? ? bootstrap_administrator : User.authenticate_by(params.permit(:email_address, :password))

    if user
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end

  private
    # There's no administrator yet to authenticate against, so accept
    # whatever was submitted and create the first one from it -- this is
    # only reachable until that first user exists.
    def bootstrap_administrator
      user = User.new(name: params[:email_address], email_address: params[:email_address],
        password: params[:password], password_confirmation: params[:password])
      user if user.save
    end
end
