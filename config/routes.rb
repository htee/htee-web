Rails.application.routes.draw do
  get '/login'  => 'application#login', as: :login
  get '/logout' => 'application#logout', as: :logout

  post '/:login(/:name)' => 'application#record'
  get  '/:login/:name'   => 'application#playback', as: :stream

  github_unauthenticated do
    get '/' => 'application#splash', as: :splash
  end

  root to: 'application#splash'

  match '*all' => 'application#not_found', via: :all
end
