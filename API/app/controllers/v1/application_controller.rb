class V1::ApplicationController < ApplicationController

   #Requests for the Schedule page
   def get_cities 
    cities = City.all
    render json: {cities: cities}
   end

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

   def get_stations_of_a_route
    route = Route.find_by(route_uid: params[:route_uid])
  
    if route
      route_stations = RouteStation.where(route_uid: route.route_uid)
      
      stations = route_stations.take(route.nr_of_stations).map do |route_station|
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

  def get_routes 
    routes = Route.all
    render json: { routes: routes }
   end

   def get_routes_by_station
    station = Station.find_by(station_uid: params[:station_uid])

    if station
      routes = station.routes.includes(:stations).distinct
      render json: {routes: routes}
    else
      render json: { error: "City or station not found!" }, status: :not_found
    end
  end

  def get_departure_times_for_station_in_route
    route = Route.find_by(route_uid: params[:route_uid])
    station = Station.find_by(station_uid: params[:station_uid])
  
    if route && station
      route_stations = RouteStation.where(route_uid: route.route_uid, station_uid: station.station_uid)
  
      if route_stations.any?
        grouped_data = route_stations.group_by(&:name).transform_values do |rs_array|
          rs_array.pluck(:departure_time).map { |time| time.strftime("%H:%M") }
        end
  
        result = grouped_data.map do |name, departure_times|
          { 'name' => name, 'departure_times' => departure_times }
        end
  
        render json: result
      else
        render json: { error: "The bus does not stop at the specified stop on the specified route" }, status: :not_found
      end
    else
      render json: { error: "Station or route not found!" }, status: :not_found
    end
  end

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
        sroutes = Route.includes(:route_stations).where(route_stations: { station_uid: sstation.station_uid }).order('route_stations.sequence ASC')
        droutes = Route.includes(:route_stations).where(route_stations: { station_uid: dstation.station_uid }).order('route_stations.sequence ASC')
        routes = sroutes & droutes

        routes.map do |route|
          route_stations = RouteStation.where(route_uid: route.route_uid, station_uid: sstation.station_uid).where('departure_time >= ?', time - 2.hours)
          if route_stations.any?
            grouped_data = group_departure_times(route_stations, date, time - 2.hours)
            comp = Company.find_by(company_uid: route.company_uid)
            result << {
              start_station: sstation.name,
              destination_station: dstation.name,
              company_name: comp.name,
              route_name: route.name,
              ticket_price: calculate_fare_sum(route.route_uid, sstation.station_uid, dstation.station_uid),
              departure_times: grouped_data.map do |name, departure_times|
                { 'name' => name, 'departure_times' => departure_times }
              end
            }
          end
        end
        render json: result 
      end
      if sstation.nil? && dstation

      end
      if sstation && dstation.nil?

      end
      if sstation.nil? && dstation.nil?
        render json: { routes: routes }
      end
    else
      render json: { error: "Start city or destination city or date or not found!" }, status: :not_found
    end
  end
  
  
    #Requests to send a confirmation email
    def send_verification_email
      user_email = params[:user_email]
      user = User.find_by(email: user_email)

      if user
        render json: { error: "User exists" }, status: :accepted
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
          render json: { error: "Error generating the code" }, status: :accepted
        end    
      end  
    end  


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

    # Fill userdata

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

end

private

def group_departure_times(route_stations, date, time)
  is_weekend = date.saturday? || date.sunday?

  route_stations.group_by(&:name).transform_values do |rs_array|
    if is_weekend
      weekend_departure_times = rs_array.select { |rs| rs.name == 'Weekend' && rs.departure_time <= time + 3.hours }.pluck(:departure_time)
      weekend_departure_times.map { |time| time.strftime("%H:%M") }
    else
      weekday_departure_times = rs_array.select { |rs| rs.name == 'Weekday' && rs.departure_time <= time + 3.hours }.pluck(:departure_time)
      weekday_departure_times.map { |time| time.strftime("%H:%M") }
    end
  end
end

def calculate_fare_sum(route, sstation, dstation)
  rs1 = RouteStation.find_by(station_uid: sstation, route_uid: route)
  rs2 = RouteStation.find_by(station_uid: dstation, route_uid: route)
  puts "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA#{route} #{sstation} #{dstation} #{rs1.fare} #{rs2.fare}"
  if rs1 && rs2
    start_sequence = rs1.sequence
    end_sequence = rs2.sequence
    puts "Start Sequence: #{start_sequence}, End Sequence: #{end_sequence}"

    stations_between = RouteStation.where(route_uid: route, sequence: start_sequence..end_sequence).distinct
    fare_sum = stations_between.sum(:fare)
    stations_between.map do |st|
      puts " FARE #{st.fare}"
    end
    return fare_sum
  else
    return 0 # or handle the case where rs1 or rs2 is not found
  end
end

