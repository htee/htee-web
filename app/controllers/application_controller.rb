class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def signin
    github_authenticate!

    User.find_or_create_by(login: github_user.login)

    redirect_to root_url
  end

  def signout
    github_logout

    redirect_to root_url
  end
end
