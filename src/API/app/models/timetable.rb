class Timetable < ApplicationRecord
    before_create :generate_uid
    
    belongs_to :route_station, foreign_key: "route_station_uid"

    private

  def generate_uid
    charset = ('0'..'9').to_a + ('A'..'Z').to_a
    self.timetable_uid = "TMT_" + (1..5).map { charset.sample }.join
  end
end
