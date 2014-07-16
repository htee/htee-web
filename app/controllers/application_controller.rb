class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, except: [:record, :update]

  before_action :authenticate, only: :record
  before_action :find_user, only: [:dash, :settings, :config_file, :delete]

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
    stream = @user.streams.create(status: :opened)

    downstream_rewrite(path: stream.path)
  end

  def playback
    @owner  = User.find_by(login: params[:owner])
    return render nothing: true, status: 404 if @owner.nil?

    @stream = @owner.streams.find_by_name(params[:name])
    return render nothing: true, status: 404 if @stream.nil?

    return render :sse if sse_supported_browser? unless event_stream_request?

    downstream_rewrite(path: @stream.path)
  end

  def dash
    @streams = @user.streams.
      paginate(:page => params[:page], :per_page => 10).
      order(created_at: :desc)
  end

  def delete
    owner = User.find_by(login: params[:owner])
    return render nothing: true, status: 401 unless @user == owner

    stream = owner.streams.find_by_name(params[:name])
    return render nothing: true, status: 404 if stream.nil?

    stream.destroy

    if request.referer == stream_url(stream.owner, stream.name)
      redirect_to dash_path
    else
      redirect_to :back
    end
  end

  def update
    owner = User.find_by(login: params[:owner])
    return render nothing: true, status: 404 if owner.nil?

    stream = owner.streams.find_by_name(params[:name])
    return render nothing: true, status: 404 if stream.nil?

    if params[:status].nil?
      return render_errors('Missing required status parameter')
    end

    status = params[:status].to_sym

    if stream.update(status: status)
      render nothing: true, status: 204
    else
      return render_errors(*stream.errors.full_messages)
    end
  end

  def ping
    render text: "PONG!"
  end

  def config_file
    render partial: 'config.toml', content_type: 'application/octet-stream'
  end

  def downstream_rewrite(request = {})
    render status: 202, json: request_hash.merge(request)
  end

  def sse_supported_browser?
    request.env['HTTP_USER_AGENT'] =~ /WebKit|Gecko|Presto/
  end

  def event_stream_request?
    request.env['HTTP_ACCEPT'] == 'text/event-stream'
  end

  def authenticate
    anon_authenticate || token_authenticate || render_unauthorized
  end

  def token_authenticate
    authenticate_or_request_with_http_token do |token, options|
      @user = User.includes(:tokens).where("tokens.key" => token).first
    end
  end

  def anon_authenticate
    if request.headers['HTTP_AUTHORIZATION'].blank?
      @user = User.anon
    end
  end

  def render_unauthorized
    self.headers['WWW-Authenticate'] = 'Token realm="Application"'
    render nothing: true, status: 401
  end

  def render_errors(*errors)
    render status: 400, json: {
      errors: errors
    }
  end

  def find_user
    @user = User.find_by(login: github_user.login)
  end

  def request_hash
    {
      method:  request.method,
      path:    request.fullpath,
    }
  end
end
