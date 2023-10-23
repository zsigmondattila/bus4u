class City < ApplicationRecord
    before_create :generate_uid

    has_many :stations, foreign_key: "city_uid"
    has_many :routes, foreign_key: "city_uid"

    def generate_uid
        charset = ('0'..'9').to_a + ('A'..'Z').to_a
        self.city_uid = "CTY_" + (1..5).map { charset.sample }.join
    end
end
