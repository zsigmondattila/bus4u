class RouteStation < ApplicationRecord
    belongs_to :bus, foreign_key: "bus_uid"
    belongs_to :station, foreign_key: "station_uid"
    belongs_to :route, foreign_key: "route_uid"
end
