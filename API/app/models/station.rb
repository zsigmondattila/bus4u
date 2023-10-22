class Station < ApplicationRecord
    before_create :generate_uid

    has_many :route_stations, foreign_key: "station_uid"
    has_many :routes, through: :route_stations
    has_many :stations_companies
    has_many :companies, through: :stations_companies

    private

  def generate_uid
    charset = ('0'..'9').to_a + ('A'..'Z').to_a
    self.station_uid = "STT_" + (1..5).map { charset.sample }.join
  end
end
