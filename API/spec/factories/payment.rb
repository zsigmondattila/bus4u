FactoryBot.define do
  factory :payment do
    payment_uid { SecureRandom.uuid }
    ticket_id { SecureRandom.uuid }
    stripe_id { SecureRandom.uuid }
  end
end
