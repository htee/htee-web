class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, except: [:record, :record_lite, :update]

  before_action :authenticate, only: :record
  before_action :find_user,    only: [:dash, :settings, :config_file, :delete]

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
    if request.xhr?
      stream = @user.streams.create(status: :created)
      render_lite_stream(stream)
    else
      stream = @user.streams.create(status: :opened)

      downstream_rewrite(path: stream.path)
    end
  end

  def record_lite
    owner = User.find_by(login: params[:owner])
    return render nothing: true, status: 404 if owner.nil?

    stream = owner.streams.find_by_name(params[:name])
    return render nothing: true, status: 404 if stream.nil?

    stream.update(status: :opened)

    downstream_rewrite(path: stream.path)
  end

  def playback
    @owner  = User.find_by(login: params[:owner])
    return render nothing: true, status: 404 if @owner.nil?

    @stream = @owner.streams.find_by_name(params[:name])
    return render nothing: true, status: 404 if @stream.nil?

    if request.xhr?
      return render nothing: true, status: 201 if @stream.created?

      return render partial: 'stream.html', locals: {stream: @stream, stream_class: "stream-full"}
    end

    if @stream.gisted?
      return redirect_to "https://gist.github.com#{@stream.gist_path}/raw", status: 301
    end

    return render :sse if sse_supported_browser? unless event_stream_request?

    downstream_rewrite(path: @stream.path)
  end

  def dash
    @streams = @user.streams.
      where.not(status: Stream.statuses[:created]).
      paginate(:page => params[:page], :per_page => 10).
      order(created_at: :desc)
  end

  def delete
    owner = User.find_by(login: params[:owner])
    return render nothing: true, status: 401 unless @user == owner

    stream = owner.streams.find_by_name(params[:name])
    return render nothing: true, status: 404 if stream.nil?

    if params[:commit] == 'gist'
      stream.gist(github_user.api, request.url)
    else
      stream.destroy
    end

    set_downstream_continue

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

  def script
    owner  = User.find_by(login: params[:owner])
    return render nothing: true, status: 404 if owner.nil?

    stream = owner.streams.find_by_name(params[:name])
    return render nothing: true, status: 404 if stream.nil?

    @lite_bin   = Htee.config.lite_bin
    @stream_url = stream_url(owner.login, stream.name)

    render :plain,
      template: 'application/script.sh',
      layout:   false
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
    github_authenticate || anon_authenticate || token_authenticate || render_unauthorized
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

  def github_authenticate
    @user = User.find_by(login: github_user.login) if github_authenticated?
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

  def render_lite_stream(stream)
    render status: 200, json: {
      owner: stream.owner,
      name: stream.name,
      status: stream.status,
      url: stream_url(stream.owner, stream.name),
      scriptURL: script_url(stream.owner, stream.name),
    }
  end

  def find_user
    @user = User.find_by(login: github_user.login)

    redirect_to logout_path if @user.nil?
  end

  def request_hash
    {
      method:  request.method,
      path:    request.fullpath,
    }
  end

  def set_downstream_continue
    response.headers['X-Htee-Downstream-Continue'] = 'yes'
  end
end
