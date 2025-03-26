FactoryBot.define do
  factory :ticket do
    ticket_uid { SecureRandom.uuid }
    company_uid { SecureRandom.uuid }
    user_uid { SecureRandom.uuid }
    ticket_type { "one_way" }
    route_uid { SecureRandom.uuid }
    from_station_uid { SecureRandom.uuid }
    to_station_uid { SecureRandom.uuid }
    date_of_purchase { Time.now }
    expiration_date { Time.now + 1.day }
    is_valid { true }
    is_paid { true }
    payment_method { 1 }
    ticket_price { 15.0 }
  end
end
