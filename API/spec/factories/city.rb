FactoryBot.define do
    factory :city do
      city_uid { SecureRandom.uuid }
      name { "Budapest" }
      zip_code { "1011" }
    end
  end
  