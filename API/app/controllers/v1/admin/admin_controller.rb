class V1::Admin::AdminController < ApplicationController
    before_action :authenticate_admin!
    
    # Statistics data for the homepage
    def statistics
        company = Company.find_by(company_uid: params[:company_uid])
        if company
            tickets = Ticket.where(company_uid: company.company_uid)
            if tickets
                month_tickets = 0
                month_users = 0
                month_income = 0
                year_tickets = 0
                year_users = 0
                year_income = 0
                all_tickets = 0
                all_users = 0
                all_income = 0

                all_tickets = tickets.count
                all_income = tickets.sum(&:ticket_price)
                all_users = tickets.map(&:user_uid).uniq.count

                year_tickets = tickets.count { |ticket| ticket.date_of_purchase >= Time.now - 1.year }
                year_income = tickets.select { |ticket| ticket.date_of_purchase >= Time.now - 1.year }.sum(&:ticket_price)
                year_users = tickets.select { |ticket| ticket.date_of_purchase >= Time.now - 1.year }.map(&:user_uid).uniq.count

                month_tickets = tickets.count { |ticket| ticket.date_of_purchase >= Time.now - 1.month }
                month_income = tickets.select { |ticket| ticket.date_of_purchase >= Time.now - 1.month }.sum(&:ticket_price)
                month_users = tickets.select { |ticket| ticket.date_of_purchase >= Time.now - 1.month }.map(&:user_uid).uniq.count

                render json: {
                    month_tickets: month_tickets,
                    month_income: month_income,
                    month_users: month_users,
                    year_tickets: year_tickets,
                    year_income: year_income,
                    year_users: year_users,
                    all_tickets: all_tickets,
                    all_income: all_income,
                    all_users: all_users
                }
            else
                render json: { error: "No tickets found" }, status: :unprocessable_entity
            end
        else
            render json: { error: "Invalid company uid!" }, status: :unprocessable_entity
        end

    end

    # Check the validity of road_taxes, insurances and technical_exams
    def document_validity_checker
        road_taxes = []
        insurances = []
        technical_exams = []
        company = Company.find_by(company_uid: params[:company_uid])
        buses = Bus.where(company_uid: company.company_uid)

        buses.each do |bus|
            if bus.technical_exam < Time.now + 2.week
                technical_exams << bus.license_plate
            end 
            if bus.insurance < Time.now + 2.week
                insurances << bus.license_plate
            end 
            if bus.road_tax < Time.now + 2.week
                road_taxes << bus.license_plate
            end
            puts "#{bus.technical_exam} #{bus.insurance} #{bus.road_tax}"
        end
        if technical_exams.empty? && insurances.empty? && road_taxes.empty?
            render json: { success: "All documents are valid in the next two weeks" }
        else
            render json: { road_taxes: road_taxes, insurances: insurances, technical_exams: technical_exams}
        end
    end

    # List of drivers at a company
    def list_of_drivers
        company = Company.find_by(company_uid: params[:company_uid])
        drivers = Admin.where(company_uid: company.company_uid, role: "driver")

        if drivers
            render json: drivers
        else 
            render json: { error: "The drivers list is empty" }, status: :unprocessable_entity
        end
    end

    # Delete a given driver
    def delete_driver
        driver = Admin.find_by(uid: params[:admin_uid])
        if driver
            if driver.role == "driver"
                driver.destroy
                render json: { success: "Driver destroyed successfully" }
            else
                render json: { error: "Cannot destroy driver" }, status: :unprocessable_entity
            end
        else
            render json: { error: "Cannot find driver" }, status: :not_found
        end
    end

    # Get a driver by his admin_uid
    def get_driver_by_id
        driver = Admin.find_by(uid: params[:admin_uid])
        if driver
            render json: driver
        else
            render json: { error: "Invalid admin_uid!" }, status: :unprocessable_entity
        end
    end

    # Update the data of a given driver
    def update_driver
        driver = Admin.find_by(uid: params[:admin_uid])
        if driver
            driver.email = params[:email] if params.key?(:email)
            driver.firstname = params[:firstname] if params.key?(:firstname)
            driver.lastname = params[:lastname] if params.key?(:lastname)
            driver.role = params[:role] if params.key?(:role)
            driver.company = Company.find_by(company_uid: params[:company_uid]) if params.key?(:company_uid)
            driver.address = params[:address] if params.key?(:address)
            driver.phone_number = params[:phone_number] if params.key?(:phone_number)
            if driver.save
                render json: { success: "Driver updated successfully" }
            else
                render json: { error: "Cannot save driver" }, status: :unprocessable_entity
            end
        else
            render json: { error: "Cannot find driver" }, status: :not_found
        end
    end
    
    #Creating a city model, it requires a name and a postal code
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

    #Creating a company model to which admin accounts can be assigned 
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

    #Creating a bus model where you can keep track of the buses, the expiration date of important papers and the current location are stored
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

    #Deleting a bus if it is no longer necessary
    def delete_bus
        bus = Bus.find_by(bus_uid: params[:bus_uid])
        if bus
            bus.destroy
            render json: { success: "Bus deleted successfully" }
        else
            render json: { error: "Invalid bud_uid!" }, status: :unprocessable_entity
        end
    end

    # Get a bus by its bus_uid
    def get_bus_by_id
        bus = Bus.find_by(bus_uid: params[:bus_uid])
        if bus
            render json: bus
        else
            render json: { error: "Invalid bus_uid!" }, status: :unprocessable_entity
        end
    end

    # Update the data of a bus
    def update_bus
        bus = Bus.find_by(bus_uid: params[:bus_uid])
        if bus
          bus.company = Company.find_by(company_uid: params[:company_uid]) if params.key?(:company_uid)
          bus.license_plate = params[:license_plate] if params.key?(:license_plate)
          bus.brand = params[:brand] if params.key?(:brand)
          bus.manufacturing_year = params[:manufacturing_year] if params.key?(:manufacturing_year)
          bus.capacity = params[:capacity] if params.key?(:capacity)
          bus.road_tax = params[:road_tax] if params.key?(:road_tax)
          bus.insurance = params[:insurance] if params.key?(:insurance)
          bus.technical_exam = params[:technical_exam] if params.key?(:technical_exam)
      
          if bus.save
            render json: { success: "Bus updated successfully" }
          else
            render json: { error: "Invalid data for updating the bus" }, status: :unprocessable_entity
          end
        else
          render json: { error: "Invalid bus_uid!" }, status: :unprocessable_entity
        end
      end

    #Creating a station where a bus can stop and user can check the exact location of it
    def create_station
        station = Station.new
        station.name = params[:name]
        station.latitude = params[:latitude]
        station.longitude = params[:longitude]
        station.city = City.find_or_create_by(name: params[:city], zip_code: params[:zip_code])
        station.address = params[:address]
        station.save
        if(station.save)       
            render json: { success: "Station created successfully" }
        else
            render json: { error: "Invalid data for creating a station" }, status: :unprocessable_entity
        end
    end

    #Delete a station is it is no longer necessary
    def delete_station
        station = Station.find_by(station_uid: params[:station_uid])
        if(station)
            station.destroy
            render json: { success: "Station deleted successfully" }
        else
            render json: { error: "Invalid data for deleting a station" }, status: :unprocessable_entity
        end
    end

    #List of routes of a company
    def get_routes_of_a_company
        routes = Route.where(company_uid: params[:company_uid])

        if !routes.empty?
            render json: { routes: routes }
        else
            render json: { error: "Routes not found!" }, status: :unprocessable_entity
        end
    end

    #List od stations of a route
    def get_stations_of_a_route
        route = Route.find_by(route_uid: params[:route_uid])
      
        if route
          route_stations = RouteStation.where(route_uid: route.route_uid)
      
          stations = route_stations.map do |route_station|
            station = Station.find_by(station_uid: route_station.station_uid)
            timetable = Timetable.find_by(route_station_uid: route_station.route_station_uid)
            
            {
              route_station_uid: route_station.route_station_uid,
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
      
    #Creating a route model for a certain company
    def create_route 
        route = Route.new
        route.name = params[:name]
        route.company_uid = params[:company_uid]
        route.basic_fare = params[:basic_fare]
        if route.save
            render json: { success: "Route created successfully",
                           route_uid: route.route_uid }
        else
            render json: { error: "Cannot create route "}, status: :unprocessable_entity
        end
    end

    #Delete a route if it is no longer necessary
    def delete_route
        route = Route.find_by(route_uid: params[:route_uid])
        if route
            route.destroy
            render json: { success: "Route deleted successfully" }
        else
            render json: { error: "Invalid data for deleting a route" }, status: :unprocessable_entity
        end
    end

    #An admin can add certaion stations to a route
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

    #An admin can delete certaion stations from a route
    def delete_station_from_route
            route_station = RouteStation.find_by(route_station_uid: params[:route_station_uid])
            if route_station.destroy
                render json: { success: "RouteStation deleted successfully" }
            else
                render json: { error: "Cannot delete RouteStation" }, status: :unprocessable_entity
            end
    end

    #An admin can add timestamps for a given station in a route
    def add_timetable_to_route
        route = Route.find_by(route_uid: params[:route_uid])
        station = Station.find_by(station_uid: params[:station_uid])
        times = params[:departure_times]
        names = params[:names]
        all_saved = true
        fare = params[:fare].to_f

        if route && station
            route_station = RouteStation.find_by(route_uid: route.route_uid, station_uid: station.station_uid) 

            names.map do |name|
                times.map do |time|
                    timetable = Timetable.new
                    timetable.route_station_uid = route_station.route_station_uid
                    timetable.departure_time = time
                    timetable.fare = fare
                    puts "AAABB #{fare}"
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

    #An admin can delete timestamps for a given station in a route
    def delete_timetables_from_route
        route = Route.find_by(route_uid: params[:route_uid])
        station = Station.find_by(station_uid: params[:station_uid])

        if route && station
            route_station = RouteStation.find_by(route_uid: route.route_uid, station_uid: station.station_uid)

            times = Timetable.where(route_station_uid: route_station.route_station_uid)
            times.each do |time|
                time.destroy
            end
                render json: { success: "Timetables deleted successfully" }
        else
            render json: { error: "Route or station not found" }, status: :unprocessable_entity
        end
    end

    #List of all buses of a company  
    def get_buses_of_a_company
        buses = Bus.where(company_uid: params[:company_uid])
        render json: buses
    end  

    #Set a bus as currently tracked (to know if it should appear on the map or not)
    def set_a_bus_tracked
        bus = Bus.find_by(license_plate: params[:license_plate])
        bus.tracked = true
        if bus.save
            render json: { success: "Bus attribute saved successfully!" }
        else
            render json: { error: "Cannot save the bus attribute!" }
        end
    end

    #Set a bus as currently untracked (to know if it should appear on the map or not)
    def set_a_bus_untracked
        bus = Bus.find_by(license_plate: params[:license_plate])
        bus.tracked = false
        if bus.save
            render json: { success: "Bus attribute saved successfully!" }
        else
            render json: { error: "Cannot save the bus attribute!" }, status: :unprocessable_entity
        end
    end

    #Set the current route of a bus on which is travelling
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

    #Set the current coordinates of a bus
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

    #Get the locations of buses on a given route
    def get_locations_by_bus_and_route
        buses = Bus.where(license_plate: params[:license_plate], current_route_uid: params[:route_uid])
        render json: buses
    end

    #Check if a ticket is valid, and if it is, then change it to invalid
    def use_ticket
        ticket = Ticket.find_by(ticket_uid: params[:ticket_uid])
        if ticket
            if ticket.expiration_date < Time.now || !ticket.is_valid
                render json: { error: "The ticket is used or expired" }, status: :unprocessable_entity
            else
                ticket.is_valid = false
                ticket.save
                render json: { success: "The ticket is validated successfully" }, status: :accepted
            end
        else
            render json: { error: "The ticket UID is invalid" }, status: :not_found
        end
    end


    def demo
        start = params[:start].to_i == 1
        index = params[:step].to_i
        route = Route.find_by(route_uid: params[:route_uid])
      
        if route.nil?
          return render json: { error: "Route not found" }, status: :not_found
        end
      
        buses = Bus.where(license_plate: BUS_OFFSETS.keys)
      
        if buses.size != 3
          return render json: { error: "3 demo buses (DEMO-001, DEMO-002, DEMO-003) are required" }, status: :unprocessable_entity
        end
      
        if start
          bus_data = []
          buses.each do |bus|
            offset = BUS_OFFSETS[bus.license_plate]
            coord_index = (index + offset) % DEMO_COORDINATES.size
            coord = DEMO_COORDINATES[coord_index]
      
            step = rand(1..2)
            coord_index = (coord_index + step) % DEMO_COORDINATES.size
            coord = DEMO_COORDINATES[coord_index]
      
            bus.update(
              latitude: coord[:lat],
              longitude: coord[:lon],
              current_route_uid: route.route_uid,
              tracked: true
            )

            bus_data << {
                license_plate: bus.license_plate,
                latitude: coord[:lat],
                longitude: coord[:lon],
                is_tracked: bus.tracked
            }
          end
      
          render json: bus_data
        else
          buses.each do |bus|
            bus.update(
              latitude: nil,
              longitude: nil,
              current_route_uid: nil,
              tracked: false
            )
          end
          render json: { success: "Demo stopped" }
        end
    end

    DEMO_COORDINATES = [
    { lat: 46.5316799666731, lon: 24.593080009632455 },
    { lat: 46.53175336455556, lon: 24.5927975933084 },
    { lat: 46.53180517409915, lon: 24.59252145234771 },
    { lat: 46.531780119327365, lon: 24.59259920045371 },
    { lat: 46.53201568016492, lon: 24.59196507733543 },
    { lat: 46.53221633557478, lon: 24.591216808480976 },
    { lat: 46.532432852567204, lon: 24.590612870595564 },
    { lat: 46.53268610845549, lon: 24.589760199617253 },
    { lat: 46.53324593912245, lon: 24.588267989617616 },
    { lat: 46.5334215828212, lon: 24.587663602582914 },
    { lat: 46.53391480030208, lon: 24.586520366484148 },
    { lat: 46.534114747086036, lon: 24.585609641825716 },
    { lat: 46.53474317877152, lon: 24.584176881182444 },
    { lat: 46.53469564326548, lon: 24.58302591104387 },
    { lat: 46.534236397975995, lon: 24.582496495310092 },
    { lat: 46.533713827504826, lon: 24.582105015681165 },
    { lat: 46.53331241093025, lon: 24.581001638091237 },
    { lat: 46.53325170415162, lon: 24.580268507715772 },
    { lat: 46.53317230617071, lon: 24.578876920730472 },
    { lat: 46.53312092424087, lon: 24.578007996036206 },
    { lat: 46.53308825254485, lon: 24.57691509071048 },
    { lat: 46.533032220545834, lon: 24.576039410306702 },
    { lat: 46.53302755070138, lon: 24.575299495571805 },
    { lat: 46.53306956606456, lon: 24.57388754631798 },
    { lat: 46.53320967899449, lon: 24.57311367512691 },
    { lat: 46.53341981226323, lon: 24.57210901899149 },
    { lat: 46.53361595955478, lon: 24.5707377792569 },
    { lat: 46.53361127935567, lon: 24.56951590986489 },
    { lat: 46.533620618492975, lon: 24.568192199911152 },
    { lat: 46.533242356249744, lon: 24.56758806866186 },
    { lat: 46.532471836883786, lon: 24.567323366223434 },
    { lat: 46.53237479944871, lon: 24.568766727429516 },
    { lat: 46.53207214653947, lon: 24.570107812551043 },
    { lat: 46.53154354483258, lon: 24.571504218123376 },
    { lat: 46.531063782423125, lon: 24.572641445277473 },
    { lat: 46.53063569946044, lon: 24.574207859585023 },
    { lat: 46.53048807170914, lon: 24.57513050448397 },
    { lat: 46.53036995472417, lon: 24.576246258647455 },
    { lat: 46.530244439584585, lon: 24.577522935768087 },
    { lat: 46.530110026203616, lon: 24.57877364336074 },
    { lat: 46.53008055321431, lon: 24.580404375260784 },
    { lat: 46.53004367452241, lon: 24.58193854650256 },
    { lat: 46.52974844303078, lon: 24.583440527451565 },
    { lat: 46.52951223916066, lon: 24.584888853270854 },
    { lat: 46.52923173957735, lon: 24.58601531661067 },
    { lat: 46.528943834509086, lon: 24.587463618496862 },
    { lat: 46.52926864801136, lon: 24.589287599881704 },
    { lat: 46.52966717430989, lon: 24.59054284223179 },
    { lat: 46.529873964500176, lon: 24.591058028965676 },
    { lat: 46.53014705162454, lon: 24.591948475263116 },
    { lat: 46.530612026169905, lon: 24.593182243684556 },
    { lat: 46.53104007628577, lon: 24.59464132966481 },
    { lat: 46.53136484871923, lon: 24.59396545169108 }
    ]

      
    BUS_OFFSETS = {
        "DEMO-001" => 0,
        "DEMO-002" => 20,
        "DEMO-003" => 45
    }

end