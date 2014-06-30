Rails.application.routes.draw do
  get '/signin'  => 'application#signin', as: :signin
  get '/signout' => 'application#signout', as: :signout

  github_unauthenticated do
    get '/' => 'application#splash', as: :splash
  end

  root to: 'application#splash'

  match '*all' => 'application#not_found', via: :all
end
