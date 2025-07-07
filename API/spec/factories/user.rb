FactoryBot.define do
  factory :user do
    uid { SecureRandom.uuid }
    provider { "email" }
    email { "user@example.com" }
    firstname { "John" }
    lastname { "Doe" }
    password { "password" }
    phone_number { "1234567890" }
    language { "en" }
    confirmed_at { Time.now }
  end
end
