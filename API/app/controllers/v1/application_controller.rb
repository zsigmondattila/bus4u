class V1::ApplicationController < ApplicationController

  #List of all cities
  def get_cities 
    cities = City.all
    render json: {cities: cities}
  end

  #List of all stations
  def get_stations 
    new_data = []
    stations = Station.all.map do |station|
    city = City.find_by(city_uid: station.city_uid)
    new_data << { station_uid: station.station_uid,
                    name: station.name, 
                    city: city.name,
                    address: station.address,
                    longitude: station.longitude, 
                    latitude: station.latitude, }
    end
    render json: {stations: new_data}
  end

  #List of all routes
  def get_routes 
    routes = Route.all
    render json: { routes: routes }
  end

  #List os stations in a given city
  def get_stations_by_city
    city = City.find_by(city_uid: params[:city_uid])
    if city
      new_data = []
      stations = city.stations.map do |station|
      new_data << { station_uid: station.station_uid,
                      name: station.name, 
                      address: station.address,
                      longitude: station.longitude, 
                      latitude: station.latitude, }
      end
      render json: {stations: new_data}
    else
      render json: { error: "Could not find the city!" }, status: :not_found
    end
  end

  #List of routes which are going through a given station
  def get_routes_by_station
    station = Station.find_by(station_uid: params[:station_uid])

    if station
      routes = station.routes.includes(:stations).distinct
      render json: {routes: routes}
    else
      render json: { error: "City or station not found!" }, status: :not_found
    end
  end

  #List of stations which appear in a given route
  def get_stations_of_a_route
      route = Route.find_by(route_uid: params[:route_uid])
    
      if route
        route_stations = RouteStation.where(route_uid: route.route_uid)
    
        stations = route_stations.map do |route_station|
          puts "abc #{route_station.sequence}"
          station = Station.find_by(station_uid: route_station.station_uid)
          
          {
            route_station_uid: route_station.route_station_uid,
            station_uid: station.station_uid,
            name: station.name,
            longitude: station.longitude,
            latitude: station.latitude,
            address: station.address,
          }
        end

        stations.each do |st|
          puts "teszt #{st}"
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

  #List of departure times in a station in a route
  def get_departure_times_for_station_in_route
    route = Route.find_by(route_uid: params[:route_uid])
    station = Station.find_by(station_uid: params[:station_uid])
  
    if route && station
      route_station = RouteStation.find_by(route_uid: route.route_uid, station_uid: station.station_uid)
  
      if route_station
        timetables = Timetable.where(route_station_uid: route_station.route_station_uid)
  
        if timetables.any?
          grouped_data = timetables.group_by(&:name).transform_values do |timetable_array|
            timetable_array.pluck(:departure_time).map { |time| time.strftime("%H:%M") }
          end
  
          result = grouped_data.map do |name, departure_times|
            { 'name' => name, 'fare' => Timetable.find_by(route_station_uid: route_station.route_station_uid, name: name).fare, 'departure_times' => departure_times }
          end
  
          render json: result
        else
          render json: { error: "No departure times found for the specified station on the specified route" }, status: :not_found
        end
      else
        render json: { error: "The bus does not stop at the specified stop on the specified route" }, status: :not_found
      end
    else
      render json: { error: "Station or route not found!" }, status: :not_found
    end
  end
      
  #List of tickets available by the parameters given by the user
  def get_available_tickets 
    scity = City.find_by(city_uid: params[:start_city_uid])
    sstation = Station.find_by(station_uid: params[:start_station_uid])
    dcity = City.find_by(city_uid: params[:destination_city_uid])
    dstation = Station.find_by(station_uid: params[:destination_station_uid])
    date = Time.zone.parse(params[:date])
    time = DateTime.strptime(params[:time], "%H:%M")
    result = []
  
    if scity && dcity && date && time
      if sstation && dstation
        sroutes = Route.includes(:route_stations).where(route_stations: { station_uid: sstation.station_uid })
        droutes = Route.includes(:route_stations).where(route_stations: { station_uid: dstation.station_uid })
        
        routes = sroutes & droutes
        process_routes(routes, sstation, dstation, date, time, result)
      elsif sstation.nil? && dstation
        scity.stations.each do |sstation|
          sroutes = Route.includes(:route_stations).where(route_stations: { station_uid: sstation.station_uid })
          droutes = Route.includes(:route_stations).where(route_stations: { station_uid: dstation.station_uid })
          routes = sroutes & droutes
          process_routes(routes, sstation, dstation, date, time, result)
        end
      elsif sstation && dstation.nil?
        dcity.stations.each do |dstation|
          sroutes = Route.includes(:route_stations).where(route_stations: { station_uid: sstation.station_uid })
          droutes = Route.includes(:route_stations).where(route_stations: { station_uid: dstation.station_uid })
          routes = sroutes & droutes
          process_routes(routes, sstation, dstation, date, time, result)
        end
      elsif sstation.nil? && dstation.nil?
        scity.stations.each do |sstation|
          dcity.stations.each do |dstation|
            sroutes = Route.includes(:route_stations).where(route_stations: { station_uid: sstation.station_uid })
            droutes = Route.includes(:route_stations).where(route_stations: { station_uid: dstation.station_uid })
            routes = sroutes & droutes

            process_routes(routes, sstation, dstation, date, time, result)
          end
        end
      end
      render json: result 
    else
      render json: { error: "Start city or destination city or date or not found!" }, status: :not_found
    end
  end


  #Generating a ticket when it is bought
  def generate_a_ticket
    user = current_user
    quantity = params[:quantity].to_i
    ticket_price = params[:ticket_price].to_i
    bought_tickets = []
    success = true
  
    if user
      quantity.times do
        ticket = Ticket.new
        ticket.company_uid = params[:company_uid]
        ticket.user_uid = user.uid
        ticket.ticket_type = params[:type]
        ticket.route_uid = params[:route_uid]
        ticket.from_station_uid = params[:from_station_uid]
        ticket.to_station_uid = params[:to_station_uid]
        ticket.date_of_purchase = Time.now 
        ticket.expiration_date = Time.now + 1.months
        ticket.ticket_price = ticket_price * 100
        ticket.is_valid = true 
        ticket.is_paid = true
    
        success = success && ticket.save
        puts "#{ticket.errors} succ"
        bought_tickets << ticket.ticket_uid
      end
    
      if success
        TicketMailer.ticket_mailer(user.email).deliver_now
        render json: bought_tickets
      else
        render json: { error: "Cannot create one or more tickets" }, status: :unprocessable_entity
      end
    else
      render json: { error: "The user is not logged in" }, status: :unauthorized
    end
  end

  #Rendering the tickets of a user
  def tickets_of_user
    results = []
    user = current_user
    if user
      tickets = Ticket.where(user_uid: user.uid)
      if tickets 
        tickets.each do |ticket|
          tostation = Station.find_by(station_uid: ticket.to_station_uid)
          fromstation = Station.find_by(station_uid: ticket.from_station_uid)
          route = Route.find_by(route_uid: ticket.route_uid)
          # Utolag valahogy torolni is kellene a kifizetetlen jegyeket
          if !ticket.is_paid
            next
          end
          results << {
            ticket_uid: ticket.ticket_uid,
            date_of_purchase: ticket.date_of_purchase,
            expiration_date: ticket.expiration_date,
            from_station_uid: ticket.from_station_uid,
            to_station_uid: ticket.to_station_uid,
            from_station_name: fromstation.name,
            to_station_name: tostation.name,
            is_valid: ticket.is_valid,
            route_uid: ticket.route_uid,
            route_name: route.name,
            ticket_price: ticket.ticket_price
          }
        end
        render json: results
      else
        render json: { error: "No tickets available" }, status: :not_found
      end
    else
      render json: { error: "User is not logged in" }, status: :unauthorized
    end
  end
  
  #Requests to send a confirmation email
  def send_verification_email
    user_email = params[:user_email]
    user = User.find_by(email: user_email)

    if user
      render json: { error: "User exists" }, status: :conflict
    else
      email_verification = EmailVerification.new
      email_verification.email  = user_email
      email_verification.save
      if email_verification.save
        email_verification = EmailVerification.find_by(email: user_email)
        code = email_verification.verification_code
        VerificationMailer.verification_mailer(user_email, code).deliver_now
        render json: { success: "Email sent succesfully" }, status: :ok
      else
        render json: { error: "Error generating the code" }, status: :conflict
      end    
    end  
  end  

  #Request to check the validity of a code given in the email
  def verify_code_email
    user_email = params[:user_email]
    code_submitted = params[:verification_code]
    email_verification = EmailVerification.find_by(email: user_email)
    code = email_verification.verification_code
    if code_submitted === code
      render json: { success: "Correct verification code" }, status: :ok
    else
      render json: { error: "The codes does not match" }, status: :unauthorized
    end    
  end 


  #Add additional data to users
  def add_userdata 
    user = User.find_by(uid: params[:user_uid])
    user.firstname = params[:firstname]
    user.lastname = params[:lastname]
    user.phone_number = params[:phone_number]
    user.language = params[:language]
    if user.save
      render json: { success: "User data saved successfully" }
    else
      render json: { error: "Cannot save userdata" }
    end
  end

  #Request to get the routes filtered by a city
  def get_routes_by_city
    city = City.find_by(city_uid: params[:city_uid])
    routes = []
    if city
      city.stations.each do |station|
        puts "megálló: #{station.name}"
        station.routes.each do |route|
          puts "----------útvonal amiben van az adott megálló: #{route.name}"
          routes << route unless routes.include?(route)
        end
      end
      render json: routes
    else
      render json: { error: 'City not found' }, status: :not_found
    end
  end

  #Request whick gives back the actual buses on a route
  def get_bus_locations_by_route
    route = Route.find_by(route_uid: params[:route_uid])
    buses = Bus.where(company_uid: route.company_uid, current_route_uid: route.route_uid, tracked: true)

    if route
      if buses
        render json: buses
      else
        render json: { error: "Cannot find any bus on the selected route" }
      end
    else
      render json: { error: "The bus uid is invalid" }, status: :unprocessable_entity
    end
  end

end

private

#Filter the suitable departure times
def filter_departure_times(route_station, date, time)
  today = date.strftime("%A")
  puts "today #{today} time #{time}"
  timetables = Timetable.where(route_station_uid: route_station.route_station_uid, name: today)
                        .pluck(:departure_time)
                        .map { |dt| dt.change(year: time.year, month: time.month, day: time.day)}
                        .select { |dt| dt >= time }
                        .map { |departure_time| departure_time.to_i }
                        .take(3)
  timetables
end

#Calculate the total price of the tour
def calculate_fare_sum(route_uid, sstation, dstation)
  rs1 = RouteStation.find_by(station_uid: sstation, route_uid: route_uid)
  rs2 = RouteStation.find_by(station_uid: dstation, route_uid: route_uid)
  route = Route.find_by(route_uid: route_uid)

  if rs1 && rs2
    start_sequence = rs1.sequence
    end_sequence = rs2.sequence

    if start_sequence < end_sequence
      stations_between = RouteStation.where(route_uid: route_uid, sequence: start_sequence..end_sequence-1)
    else
      stations_between = RouteStation.where(route_uid: route_uid, sequence: end_sequence..start_sequence-1)
    end

    fare_sum = 0

    stations_between.each do |station|
      timetable = Timetable.find_by(route_station_uid: station.route_station_uid)

      fare_sum += timetable.fare
    end

    return fare_sum + route.basic_fare
  else
    return 0
  end
end


#Generate the final format of the response
def process_routes(routes, start_station, destination_station, date, time, result)
  routes.each do |route|
    route_station = RouteStation.find_by(route_uid: route.route_uid, station_uid: start_station.station_uid)

    if route_station
      sel_time = Time.now.change(hour: time.hour, min: time.min)
      puts "A valasz #{sel_time}"
      filtered_departure_times = filter_departure_times(route_station, date, sel_time)

      comp = Company.find_by(company_uid: route.company_uid)

      filtered_departure_times.each do |departure_time|
        result << {
          from_station: start_station.name,
          from_station_uid: start_station.station_uid,
          to_station: destination_station.name,
          to_station_uid: destination_station.station_uid,
          company_name: comp.name,
          company_uid: comp.company_uid,
          route_name: route.name,
          route_uid: route.route_uid,
          ticket_price: calculate_fare_sum(route.route_uid, start_station.station_uid, destination_station.station_uid),
          departure_time: departure_time
        }
      end
    end
  end
end


