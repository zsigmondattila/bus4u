class Bus < ApplicationRecord
    before_create :generate_uid
    
    belongs_to :company, foreign_key: "company_uid"
    has_many :route_stations, foreign_key: "bus_uid"

    private

  def generate_uid
    charset = ('0'..'9').to_a + ('A'..'Z').to_a
    self.bus_uid = "BUS_" + (1..5).map { charset.sample }.join
  end
end
