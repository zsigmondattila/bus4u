class Price < ApplicationRecord
    belongs_to :company, foreign_key: "company_uid"
    belongs_to :route, foreign_key: "route_uid"
    belongs_to :from_station, class_name: 'Station', foreign_key: 'from_station_uid'
    belongs_to :to_station, class_name: 'Station', foreign_key: 'to_station_uid'
    has_one :price, foreign_key: "price_uid"
end
