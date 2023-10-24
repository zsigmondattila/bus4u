class V1::ApplicationController < ApplicationController

   #Requests for the Schedule page
   def get_cities 
    cities = City.all
    render json: {cities: cities}
   end

   def get_stations_by_city
    city = City.find_by(name: params[:name])
    if city
      stations = city.stations
      render json: {stations: stations}
    else
      render json: { error: "Could not find the city!" }, status: :not_found
    end
   end

   def get_routes_by_city_and_station
    city = City.find_by(name: params[:city])
    station = Station.find_by(name: params[:station])

    if city && station
      routes = city.routes.includes(:stations).where(stations: { station_uid: station.station_uid })
      render json: {routes: routes}
    else
      render json: { error: "City or station not found!" }, status: :not_found
    end
  end

  def get_departure_times_for_station_in_route
    route = Route.find_by(name: params[:route])
    station = Station.find_by(name: params[:station])
  
    if route && station
      route_stations = RouteStation.where(route_uid: route.route_uid, station_uid: station.station_uid)
  
      if route_stations.any?
        departure_times = route_stations.pluck(:departure_time)
        render json: { departure_times: departure_times.map { |time| time.strftime("%H:%M") } }
      else
        render json: { error: "The bus does not stop at the specified stop on the specified route" }, status: :not_found
      end
    else
      render json: { error: "Station or route not found!" }, status: :not_found
    end
end


end
