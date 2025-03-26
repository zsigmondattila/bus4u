FactoryBot.define do
  factory :company do
    company_uid { SecureRandom.uuid }
    name { "Company A" }
    email { "company@example.com" }
    phone_number { "1234567890" }
    tax_number { "12345678" }
    city { "Budapest" }
    office_address { "Some office address" }
  end
end
