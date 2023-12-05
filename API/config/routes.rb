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
      post '/create_route', to: 'admin#create_route'
      post '/add_station_to_route', to: 'admin#add_station_to_route'
      post '/add_timetable_to_route', to: 'admin#add_timetable_to_route'
      post '/create_ticket', to: 'admin#create_ticket'
      post '/set_a_bus_tracked', to: 'admin#set_a_bus_tracked'
      post '/set_a_bus_untracked', to: 'admin#set_a_bus_untracked'
      post '/set_current_route_of_a_bus', to: 'admin#set_current_route_of_a_bus'
      post '/change_bus_location', to: 'admin#change_bus_location'
      post '/use_ticket', to:'admin#use_ticket'
      get '/get_routes_of_a_company', to: 'admin#get_routes_of_a_company'
      get '/get_stations_of_a_route', to: 'admin#get_stations_of_a_route'
      get '/get_buses_of_a_company', to: 'admin#get_buses_of_a_company'

    end
    post '/send_verification_email', to: 'application#send_verification_email'
    get '/verify_code_email', to: 'application#verify_code_email'
    post '/add_userdata', to: 'application#add_userdata'
    get '/get_cities', to: 'application#get_cities'
    get '/get_stations', to: 'application#get_stations'
    get '/get_stations_by_city', to: 'application#get_stations_by_city'
    get '/get_stations_of_a_route', to: 'application#get_stations_of_a_route'
    get '/get_routes', to: 'application#get_routes'
    get '/get_routes_by_station', to: 'application#get_routes_by_station'
    get '/get_departure_times_for_station_in_route', to:'application#get_departure_times_for_station_in_route'
    get '/get_available_tickets', to: 'application#get_available_tickets'
    post '/generate_a_cash_ticket', to: 'application#generate_a_cash_ticket'
    post '/generate_a_card_ticket', to: 'application#generate_a_card_ticket'
  end

  # Defines the root path route ("/")
  get '/', to: "home#index"
end
