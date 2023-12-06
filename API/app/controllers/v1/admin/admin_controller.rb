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
        if company.save
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
        if bus.save
            render json: { success: "Bus created successfully" }
        else
            render json: { error: "Invalid data for creating a bus" }, status: :unprocessable_entity
        end
    end

    def delete_bus
        bus = Bus.find_by(bus_uid: params[:bus_uid])
        if bus
            bus.destroy
            render json: { success: "Bus deleted successfully" }
        else
            render json: { error: "Invalid data for deleting a bus" }, status: :unprocessable_entity
        end
    end

    def create_station
        station = Station.new
        station.name = params[:name]
        station.latitude = params[:latitude]
        station.longitude = params[:longitude]
        station.city = City.find_or_create_by(name: params[:city])
        station.address = params[:address]
        station.save
        if(station.save)       
            render json: { success: "Station created successfully" }
        else
            render json: { error: "Invalid data for creating a station" }, status: :unprocessable_entity
        end
    end

    def delete_station
        station = Station.find_by(station_uid: params[:station_uid])
        if(station)
            station.destroy
            render json: { success: "Station deleted successfully" }
        else
            render json: { error: "Invalid data for deleting a station" }, status: :unprocessable_entity
        end
    end

    def get_routes_of_a_company
        routes = Route.where(company_uid: params[:company_uid])

        if !routes.empty?
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
            timetable = Timetable.find_by(route_station_uid: route_station.route_station_uid)
            
            {
              station_uid: station.station_uid,
              name: station.name,
              longitude: station.longitude,
              latitude: station.latitude,
              address: station.address,
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
        route.basic_fare = params[:basic_fare]
        if route.save
            render json: { success: "Route created successfully" }
        else
            render json: { error: "Cannot create route "}, status: :unprocessable_entity
        end
    end

    def delete_route
        route = Route.find_by(route_uid: params[:route_uid])
        if(route.destroy)
            render json: { success: "Route deleted successfully" }
        else
            render json: { error: "Invalid data for deleting a route" }, status: :unprocessable_entity
        end
    end

    def add_station_to_route 
        route = Route.find_by(route_uid: params[:route_uid])
        station = Station.find_by(station_uid: params[:station_uid])

        if route && station
            route_station = RouteStation.new
            route_station.route_uid = route.route_uid
            route_station.station_uid = station.station_uid
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

    def delete_station_from_route
        route = Route.find_by(route_uid: params[:route_uid])
        station = Station.find_by(station_uid: params[:station_uid])

        if route && station
            route_station = RouteStation.where(route_uid: route.route_uid, station_uid: station.station_uid)
            if route_station.destroy_all
                render json: { success: "RouteStation deleted successfully" }
            else
                render json: { error: "Cannot delete RouteStation" }, status: :unprocessable_entity
            end
        else
            render json: { error: "Route or station not found" }, status: :unprocessable_entity
        end
    end

    def add_timetable_to_route
        route = Route.find_by(route_uid: params[:route_uid])
        station = Station.find_by(station_uid: params[:station_uid])
        times = params[:departure_times]
        names = params[:names]
        all_saved = true

        if route && station
            route_station = RouteStation.find_by(route_uid: route.route_uid, station_uid: station.station_uid) 

            names.map do |name|
                times.map do |time|
                    timetable = Timetable.new
                    timetable.route_station_uid = route_station.route_station_uid
                    timetable.departure_time = time
                    timetable.fare = params[:fare]
                    timetable.name = name

                    if !timetable.save
                        all_saved = false
                    end
                end
            end
            if all_saved
                render json: { success: "Timetable saved successfully" }
            else
                render json: { error: "Cannot save timetable" }, status: :unprocessable_entity
            end
        else
            render json: { error: "Route or station not found" }, status: :unprocessable_entity
        end
    end
      
    def get_buses_of_a_company
        buses = Bus.where(company_uid: params[:company_uid])
        render json: buses
    end  

    def set_a_bus_tracked
        bus = Bus.find_by(license_plate: params[:license_plate])
        bus.tracked = true
        if bus.save
            render json: { success: "Bus attribute saved successfully!" }
        else
            render json: { error: "Cannot save the bus attribute!" }
        end
    end

    def set_a_bus_untracked
        bus = Bus.find_by(license_plate: params[:license_plate])
        bus.tracked = false
        if bus.save
            render json: { success: "Bus attribute saved successfully!" }
        else
            render json: { error: "Cannot save the bus attribute!" }, status: :unprocessable_entity
        end
    end

    def set_current_route_of_a_bus
        bus = Bus.find_by(license_plate: params[:license_plate])
        route = Route.find_by(route_uid: params[:route_uid])
        if route
            bus.current_route_uid = params[:route_uid]
            if bus.save
                render json: { success: "Current route saved successfully!" }
            else
                render json: { error: "Cannot save current route" }, status: :unprocessable_entity
            end
        else
            render json: { error: "Route does not exist" }, status: :unprocessable_entity
        end
    end

    def change_bus_location
        bus = Bus.find_by(license_plate: params[:license_plate])
        route = Route.find_by(route_uid: params[:route_uid])

        bus.current_route_uid = route.route_uid
        bus.latitude = params[:latitude]
        bus.longitude = params[:longitude]
        if bus.save
            render json: { success: "Location updated successfully" }
        else
            render json: { error: "Cannot update location" }, status: :unprocessable_entity
        end
    end

    def get_locations_by_bus_and_route
        buses = Bus.where(license_plate: params[:license_plate], current_route_uid: params[:route_uid])
        render json: buses
    end

    def use_ticket
        ticket = Ticket.find_by(ticket_uid: params[:ticket_uid])
        if ticket
            if ticket.expiration_date < Time.now || !ticket.is_valid
                render json: { error: "The ticket is used or expired" }, status: :unprocessable_entity
            else
                ticket.is_valid = false
                ticket.save
                render json: { success: "The ticked is validated successfully" }, status: :accepted
            end
        else
            render json: { error: "The ticket UID is invalid" }, status: :not_found
        end
    end

end