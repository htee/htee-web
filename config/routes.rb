Rails.application.routes.draw do
  get '/login'  => 'application#login', as: :login
  get '/logout' => 'application#logout', as: :logout

  post '/:login(/:name)' => 'application#record'
  get  '/:login/:name'   => 'application#playback', as: :stream

  github_authenticated do
    get '/' => 'application#dash', as: :dash
  end

  get '/' => 'application#splash', as: :splash

  root to: 'application#splash'

  match '*all' => 'application#not_found', via: :all
end
