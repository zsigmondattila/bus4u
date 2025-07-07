FactoryBot.define do
  factory :bus do
    bus_uid { SecureRandom.uuid }
    company_uid { SecureRandom.uuid }
    license_plate { "ABC123" }
    brand { "Volvo" }
    manufacturing_year { 2020 }
    capacity { 50 }
    road_tax { Time.now }
    insurance { Time.now }
    technical_exam { Time.now }
    tracked { true }
    latitude { 47.497942 }
    longitude { 19.040236 }
  end
end
