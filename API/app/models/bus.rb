class Bus < ApplicationRecord
    belongs_to :company, foreign_key: "company_uid"
    has_many :route_stations, foreign_key: "bus_uid"
end
