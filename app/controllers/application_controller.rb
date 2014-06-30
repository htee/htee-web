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

  def record
    if user = User.find_by(login: params[:login])
      if params[:name].blank?
        stream = user.streams.create
      else
        stream = user.streams.find_or_create_by(name: params[:name])
      end

      response.headers["Location"] = stream.path
      render nothing: true, status: 204
    else
      render nothing: true, status: 403
    end
  end

  def playback
    if user = User.find_by(login: params[:login])
      if stream = user.streams.find_by_name(params[:name])
        render nothing: true, status: 204
      else
        render nothing: true, status: 404
      end
    else
      render nothing: true, status: 404
    end
  end
end
