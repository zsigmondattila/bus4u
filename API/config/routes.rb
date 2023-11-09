Rails.application.routes.draw do
  get 'home/index'
  mount_devise_token_auth_for 'User', at: 'auth'

  mount_devise_token_auth_for 'Admin', at: 'admin'
  as :admin do
    # Define routes for Admin within this block.
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  namespace :v1 do
    namespace :admin do
      #Superuser requests
      post '/create_city', to: 'admin#create_city'
      post '/create_company', to: 'admin#create_company'
      post '/create_bus', to: 'admin#create_bus'
      post '/create_station', to: 'admin#create_station'
      get '/get_routes_of_a_company', to: 'admin#get_routes_of_a_company'
    end
    get '/get_cities', to: 'application#get_cities'
    get '/get_stations_by_city', to: 'application#get_stations_by_city'
    get '/get_routes_by_station', to: 'application#get_routes_by_station'
    get '/get_departure_times_for_station_in_route', to:'application#get_departure_times_for_station_in_route'
  end

  # Defines the root path route ("/")
  get '/', to: "home#index"
end
