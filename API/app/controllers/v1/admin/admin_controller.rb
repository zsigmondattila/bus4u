class V1::Admin::AdminController < ApplicationController
    
    def create_city
        city = City.new
        city.name = params[:name]
        city.zip_code = params[:zip_code]
        city.save
        if(city.save)
            render json: { success: "City created successfully" }
        else
            render json: { error: "Invalid data for creating a city" }, status: :unprocessable_entity        
        end
    end

    def create_company
        company = Company.new
        company.name = params[:name]
        company.email = params[:email]
        company.phone_number = params[:phone_number]
        company.tax_number = params[:tax_number]
        company.city = params[:city]
        company.office_address = params[:office_address]
        if(company.save)
            render json: { success: "Company created successfully" }
        else
            render json: { error: "Invalid data for creating a company" }, status: :unprocessable_entity        
        end
    end

    def create_bus
        bus = Bus.new
        bus.company = Company.find_by(company_uid: params[:company_uid])
        bus.license_plate = params[:license_plate]
        bus.brand = params[:brand]
        bus.manufacturing_year = params[:manufacturing_year]
        bus.capacity = params[:capacity]
        bus.road_tax = params[:road_tax]
        bus.insurance = params[:insurance]
        bus.technical_exam = params[:technical_exam]
        bus.save
        if(bus.save)
            render json: { success: "Bus created successfully" }
        else
            render json: { error: "Invalid data for creating a bus" }, status: :unprocessable_entity
        end
    end

    def create_station
        station = Station.new
        station.name = params[:name]
        station.latitude = params[:latitude]
        station.longitude = params[:longitude]
        station.city = City.find_by(name: params[:city])
        station.address = params[:address]
        station.save
        if(station.save)       
            render json: { success: "Station created successfully" }
        else
            render json: { error: "Invalid data for creating a station" }, status: :unprocessable_entity
        end
    end

    def get_routes_of_a_company
        routes = Route.where(company_uid: params[:company_uid])

        if routes
            render json: { routes: routes }
        else
            render json: { error: "Routes not found!" }, status: :unprocessable_entity
        end
    end

    def get_stations_of_a_route
        route = Route.find_by(route_uid: params[:route_uid])
      
        if route
          route_stations = RouteStation.where(route_uid: route.route_uid)
      
          stations = route_stations.map do |route_station|
            station = Station.find_by(station_uid: route_station.station_uid)
            {
              station_uid: station.station_uid,
              name: station.name,
              longitude: station.longitude,
              latitude: station.latitude,
              address: station.address,
              departure_time: route_station.departure_time.strftime("%H:%M"),
              sequence: route_station.sequence
            }
          end
      
          if stations
            render json: { stations: stations }
          else
            render json: { error: "Stations not found!" }, status: :unprocessable_entity
          end
        else 
          render json: { error: "Route not found!" }, status: :unprocessable_entity
        end
      end

    def create_route 
        route = Route.new
        route.name = params[:name]
        route.company_uid = params[:company_uid]
        if route.save
            render json: { success: "Route created successfully" }
        else
            render json: { error: "Cannot create route "}, status: :unprocessable_entity
        end
    end

    def add_station_to_route 
        route = Route.find_by(route_uid: params[:route_uid])
        station = Station.find_by(station_uid: params[:station_uid])

        if route && station
            route_station = RouteStation.new
            route_station.route_uid = route.route_uid
            route_station.station_uid = station.station_uid
            route_station.departure_time = params[:departure_time]
            route_station.sequence = params[:sequence]
        
            if route_station.save
                render json: { success: "RouteStation created successfully" }
            else
                render json: { error: "Cannot create RouteStation" }, status: :unprocessable_entity
            end
        else
            render json: { error: "Route or station not found" }, status: :unprocessable_entity
        end
    end

end