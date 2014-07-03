Rails.application.routes.draw do
  get '/login'  => 'application#login', as: :login
  get '/logout' => 'application#logout', as: :logout

  github_authenticated do
    get '/settings/htee.conf' => 'application#config_file', as: :config
    get '/settings'           => 'application#settings', as: :settings
    get '/'                   => 'application#dash', as: :dash
  end

  post '/:owner(/:name)' => 'application#record'
  get  '/:owner/:name'   => 'application#playback', as: :stream

  get '/' => 'application#splash', as: :splash

  root to: 'application#splash'

  match '*all' => 'application#not_found', via: :all
end
