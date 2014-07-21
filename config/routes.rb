Rails.application.routes.draw do
  get '/login'  => 'application#login', as: :login
  post '/login' => 'application#login'
  get '/logout' => 'application#logout', as: :logout
  get '/ping'   => 'application#ping'

  github_authenticated do
    get '/settings/htee.conf' => 'application#config_file', as: :config
    get '/settings'           => 'application#settings', as: :settings

    delete '/:owner/:name' => 'application#delete'

    get '/' => 'application#dash', as: :dash
  end

  post '/:owner/:name'    => 'application#record_lite'
  post '/'                => 'application#record'
  put  '/:owner/:name'    => 'application#update'
  get  '/:owner/:name.sh' => 'application#script', as: :script
  get  '/:owner/:name'    => 'application#playback', as: :stream

  get '/' => 'application#splash', as: :splash

  root to: 'application#splash'

  match '*all' => 'application#not_found', via: :all
end
