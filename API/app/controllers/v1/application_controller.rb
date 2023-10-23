class V1::ApplicationController < ApplicationController

    def hello
        render json: {welcome: "Szerusz"}
    end

    def list_of_stations_by_city
        city = City.find(params[:city])
        render json: city.stations
    end

    def get_schedules_of_a_route 
        route = params[:route]
        station = params[:station]
    end
end
