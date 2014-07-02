class ApplicationController < ActionController::Base
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
    user = User.find_by(login: params[:login])
    return render nothing: true, status: 403 if user.nil?

    if params[:name].blank?
      stream = user.streams.create
    else
      stream = user.streams.find_or_create_by(name: params[:name])
    end

    downstream_continue(stream)
  end

  def playback
    @user = User.find_by(login: params[:login])
    return render nothing: true, status: 404 if @user.nil?

    @stream = @user.streams.find_by_name(params[:name])
    return render nothing: true, status: 404 if @stream.nil?

    return render :sse if sse_supported_browser? unless event_stream_request?

    downstream_continue(@stream)
  end

  def downstream_continue(stream)
    render nothing: true, status: 204, location: stream.path
  end

  def sse_supported_browser?
    request.env['HTTP_USER_AGENT'] =~ /WebKit|Gecko|Presto/
  end

  def event_stream_request?
    request.env['HTTP_ACCEPT'] == 'text/event-stream'
  end
end
