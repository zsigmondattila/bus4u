FactoryBot.define do
  factory :station do
    station_uid { SecureRandom.uuid }
    name { "Station 1" }
    address { "Some address" }
    city_uid { SecureRandom.uuid }
    latitude { 47.497942 }
    longitude { 19.040236 }
  end
end
