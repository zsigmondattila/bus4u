class V1::ApplicationController < ApplicationController

   def get_cities 
    cities = City.all
    render json: cities
   end

   def get_stations_by_city
    city = City.find_by(name: params[:name])
    if city
      stations = city.stations
      render json: stations
    else
      render json: { error: "Could not find the city!" }, status: :not_found
    end
   end

   def get_routes_by_city_and_station
    city = City.find_by(name: params[:city])
    station = Station.find_by(name: params[:station])

    if city && station
      routes = city.routes.includes(:stations).where(stations: { station_uid: station.station_uid })
      render json: { routes: routes }
    else
      render json: { error: "City or station not found!" }, status: :not_found
    end
  end

end
