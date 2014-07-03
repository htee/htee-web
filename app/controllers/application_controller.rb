class ApplicationController < ActionController::Base
  before_action :authenticate, only: :record

  def login
    github_authenticate!

    user = User.find_or_create_by(login: github_user.login)

    if user.email != github_user.email || user.name != github_user.name
      user.update(email: github_user.email, name: github_user.name)
    end

    redirect_to root_url
  end

  def logout
    github_logout

    redirect_to root_url
  end

  def record
    owner = User.find_by(login: params[:login])
    return render_unauthorized if owner != @user

    if params[:name].blank?
      stream = @user.streams.create
    else
      stream = @user.streams.find_or_create_by(name: params[:name])
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

  def dash
    @user    = User.find_by(login: github_user.login)
    @streams = @user.streams.
      paginate(:page => params[:page], :per_page => 10).
      order(created_at: :desc)
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

  def authenticate
    token_authenticate! || render_unauthorized
  end

  def token_authenticate!
    authenticate_or_request_with_http_token do |token, options|
      @user = User.includes(:tokens).where("tokens.key" => token).first
    end
  end

  def render_unauthorized
    self.headers['WWW-Authenticate'] = 'Token realm="Application"'
    render nothing: true, status: 401
  end
end
