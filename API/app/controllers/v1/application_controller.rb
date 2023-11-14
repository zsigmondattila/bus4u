class V1::ApplicationController < ApplicationController

   #Requests for the Schedule page
   def get_cities 
    cities = City.all
    render json: {cities: cities}
   end

   def get_stations_by_city
    city = City.find_by(city_uid: params[:city_uid])
    if city
      stations = city.stations
      render json: {stations: stations}
    else
      render json: { error: "Could not find the city!" }, status: :not_found
    end
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
          departure_times = route_stations.pluck(:departure_time)
          render json: { departure_times: departure_times.map { |time| time.strftime("%H:%M") } }
        else
          render json: { error: "The bus does not stop at the specified stop on the specified route" }, status: :not_found
        end
      else
        render json: { error: "Station or route not found!" }, status: :not_found
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
          render json: { email: "Email sent succesfully" }, status: :ok
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
