FactoryBot.define do
  factory :route do
    route_uid { SecureRandom.uuid }
    company_uid { SecureRandom.uuid }
    name { "Route 1" }
    nr_of_stations { 10 }
    basic_fare { 2.5 }
  end
end
