FactoryBot.define do
  factory :route_station do
    route_uid { SecureRandom.hex(10) }
    station_uid { SecureRandom.hex(10) }
    sequence(:sequence) { |n| n } # Az n az egyedi index, amit a factory generál
  end
end
