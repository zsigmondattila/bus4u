class Station < ApplicationRecord
    has_many :route_stations, foreign_key: "station_uid"
end
