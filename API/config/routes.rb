Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  mount_devise_token_auth_for 'Admin', at: 'admin'
  as :admin do
    # Define routes for Admin within this block.
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  namespace :v1 do 
    get '/get_cities', to: 'application#get_cities'
    get '/get_stations_by_city', to: 'application#get_stations_by_city'
    get '/get_routes_by_city_and_station', to: 'application#get_routes_by_city_and_station'
  end

  # Defines the root path route ("/")
  # root "articles#index"
end
