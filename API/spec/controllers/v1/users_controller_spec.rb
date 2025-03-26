require 'rails_helper'

RSpec.describe V1::UserController, type: :controller do

  describe 'GET #get_cities' do
    it 'returns a list of cities' do
      create(:city, name: 'Budapest')
      create(:city, name: 'Debrecen')

      get :get_cities

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Budapest')
      expect(response.body).to include('Debrecen')
    end
  end

  describe 'GET #get_stations' do
    it 'returns a list of stations' do
      city = create(:city, name: 'Budapest')
      create(:station, name: 'Keleti', city: city)

      get :get_stations

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Keleti')
      expect(response.body).to include('Budapest')
    end
  end

  describe 'GET #get_routes' do
    it 'returns a list of routes' do
      company = create(:company)
      create(:route, name: 'Route 1', company: company)
      create(:route, name: 'Route 2', company: company)
    
      get :get_routes
    
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Route 1')
      expect(response.body).to include('Route 2')
    end
  end

  describe 'GET #get_stations_by_city' do
    it 'returns stations for a given city' do
      city = create(:city, name: 'Budapest')
      create(:station, name: 'Keleti', city: city)

      get :get_stations_by_city, params: { city_uid: city.city_uid }

      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)

      expect(json_response['stations'].first['name']).to eq('Keleti')
      expect(json_response['stations'].first['address']).to eq('Some address')
    end

    it 'returns an error if city is not found' do
      get :get_stations_by_city, params: { city_uid: 'nonexistent_uid' }

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include('Could not find the city!')
    end
  end

  describe 'GET #get_routes_by_station' do
    it 'returns routes for a given station' do
      city = create(:city, name: 'Budapest')
      station = create(:station, name: 'Keleti', city: city)
      route = create(:route, name: 'Route 1', company: create(:company))
      create(:route_station, route: route, station: station)

      get :get_routes_by_station, params: { station_uid: station.station_uid }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Route 1')
    end

    it 'returns an error if station is not found' do
      get :get_routes_by_station, params: { station_uid: 'nonexistent_uid' }

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include('City or station not found!')
    end
  end

  describe 'GET #get_stations_of_a_route' do
    it 'returns stations for a given route' do
      company = create(:company)
      route = create(:route, company: company)
      city = create(:city, name: 'Budapest')
      station = create(:station, name: 'Keleti', city: city)
      create(:route_station, route: route, station: station)

      get :get_stations_of_a_route, params: { route_uid: route.route_uid }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Keleti')
      expect(response.body).not_to include('Route 1')
    end

    it 'returns an error if route is not found' do
      get :get_stations_of_a_route, params: { route_uid: 'nonexistent_uid' }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include('Route not found!')
    end
  end

end
