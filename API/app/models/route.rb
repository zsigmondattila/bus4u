class Route < ApplicationRecord
    has_many :route_stations, foreign_key: "route_uid"
    has_many :prices, foreign_key: "route_uid"
end
