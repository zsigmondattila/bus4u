class RouteStation < ApplicationRecord
    before_create :generate_uid
    
    belongs_to :station, foreign_key: "station_uid"
    belongs_to :route, foreign_key: "route_uid"

    private

  def generate_uid
    charset = ('0'..'9').to_a + ('A'..'Z').to_a
    self.route_station_uid = "RST_" + (1..5).map { charset.sample }.join
  end
end
