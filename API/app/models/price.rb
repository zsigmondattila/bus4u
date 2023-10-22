class Price < ApplicationRecord
    before_create :generate_uid
    
    belongs_to :company, foreign_key: "company_uid"
    belongs_to :route, foreign_key: "route_uid"
    belongs_to :from_station, class_name: 'Station', foreign_key: 'from_station_uid'
    belongs_to :to_station, class_name: 'Station', foreign_key: 'to_station_uid'
    has_one :price, foreign_key: "price_uid"

    private

  def generate_uid
    charset = ('0'..'9').to_a + ('A'..'Z').to_a
    self.price_uid = "PRC_" + (1..5).map { charset.sample }.join
  end
end
