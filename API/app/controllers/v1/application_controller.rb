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
    puts "timee #{time}"
    result = []
  
    if scity && dcity && date && time
      if sstation && dstation
        sroutes = Route.includes(:route_stations).where(route_stations: { station_uid: sstation.station_uid }).order('route_stations.sequence ASC')
        droutes = Route.includes(:route_stations).where(route_stations: { station_uid: dstation.station_uid }).order('route_stations.sequence ASC')
        routes = sroutes & droutes
        process_routes(routes, sstation, dstation, date, time, result)
      elsif sstation.nil? && dstation
        scity.stations.each do |sstation|
          sroutes = Route.includes(:route_stations).where(route_stations: { station_uid: sstation.station_uid }).order('route_stations.sequence ASC')
          droutes = Route.includes(:route_stations).where(route_stations: { station_uid: dstation.station_uid }).order('route_stations.sequence ASC')
          routes = sroutes & droutes
          process_routes(routes, sstation, dstation, date, time, result)
        end
      elsif sstation && dstation.nil?
        dcity.stations.each do |dstation|
          sroutes = Route.includes(:route_stations).where(route_stations: { station_uid: sstation.station_uid }).order('route_stations.sequence ASC')
          droutes = Route.includes(:route_stations).where(route_stations: { station_uid: dstation.station_uid }).order('route_stations.sequence ASC')
          routes = sroutes & droutes
          process_routes(routes, sstation, dstation, date, time, result)
        end
      elsif sstation.nil? && dstation.nil?
        scity.stations.each do |sstation|
          dcity.stations.each do |dstation|
            sroutes = Route.includes(:route_stations).where(route_stations: { station_uid: sstation.station_uid }).order('route_stations.sequence ASC')
            droutes = Route.includes(:route_stations).where(route_stations: { station_uid: dstation.station_uid }).order('route_stations.sequence ASC')
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

  def generate_a_cash_ticket
    quantity = params[:quantity].to_i
    ticket_price = params[:ticket_price]
    success = true
  
    quantity.times do
      ticket = Ticket.new
      ticket.company_uid = params[:company_uid]
      ticket.user_uid = params[:user_uid]
      ticket.type = params[:type]
      ticket.route_uid = params[:route_uid]
      ticket.from_station_uid = params[:from_station_uid]
      ticket.to_station_uid = params[:to_station_uid]
      ticket.date_of_purchase = Time.now 
      ticket.expiration_date = Time.now + 1.months
      ticket.ticket_price = ticket_price * 100
      ticket.is_valid = true 
      ticket.is_paid = false
  
      success = success && ticket.save
    end
  
    if success
      render json: { success: "All tickets created successfully" }
    else
      render json: { error: "Cannot create one or more tickets" }, status: :unprocessable_entity
    end
  end
  

  def generate_a_card_ticket
    quantity = params[:quantity].to_i
    ticket_price = params[:ticket_price] 

    quantity.times do
      ticket = Ticket.new(order_params.merge(ticket_price: ticket_price*100, payment_method: 'credit_card'))
      ticket.company_uid = params[:company_uid]
      ticket.user_uid = params[:user_uid]
      ticket.type = params[:type]
      ticket.route_uid = params[:route_uid]
      ticket.from_station_uid = params[:from_station_uid]
      ticket.to_station_uid = params[:to_station_uid]
      ticket.date_of_purchase = Time.now 
      ticket.expiration_date = Time.now + 1.months
      ticket.is_valid = true 
      ticket.is_paid = false
      if ticket.save
        render json: { success: "Ticket created successfully" }
      else
        render json: {error: @response.errors}, status: :unprocessable_entity
      end
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

def filter_departure_times(route_stations, date, time)
  is_weekend = date.saturday? || date.sunday?
  filter_name = is_weekend ? 'Weekend' : 'Weekday'
  time3 = time + 3.hours

  filtered_departure_times = route_stations
    .select { |rs| rs.name == filter_name && rs.departure_time.strftime("%H:%M") >= time.strftime("%H:%M") && rs.departure_time.strftime("%H:%M") < time3.strftime("%H:%M") }
    .pluck(:departure_time)
    .map { |time| time.strftime("%H:%M") }

  filtered_departure_times
end


def calculate_fare_sum(route, sstation, dstation)
  rs1 = RouteStation.find_by(station_uid: sstation, route_uid: route)
  rs2 = RouteStation.find_by(station_uid: dstation, route_uid: route)
  if rs1 && rs2
    start_sequence = rs1.sequence
    end_sequence = rs2.sequence

    stations_between = RouteStation.where(route_uid: route, sequence: start_sequence..end_sequence).distinct
    fare_sum = stations_between.sum(:fare)
    return fare_sum
  else
    return 0
  end
end

def process_routes(routes, start_station, destination_station, date, time, result)
  routes.map do |route|
    route_stations = RouteStation.where(route_uid: route.route_uid, station_uid: start_station.station_uid)

    if route_stations.any?
      filtered_departure_times = filter_departure_times(route_stations, date, time)
      comp = Company.find_by(company_uid: route.company_uid)
      result << {
        start_station: start_station.name,
        destination_station: destination_station.name,
        company_name: comp.name,
        route_name: route.name,
        ticket_price: calculate_fare_sum(route.route_uid, start_station.station_uid, destination_station.station_uid),
        departure_times: filtered_departure_times
      }
    end
  end
end

def order_params
  params.require(:data).permit(:user_uid, :credit_card_number, :credit_card_exp_month, :credit_card_exp_year, :credit_card_cvv)
end

