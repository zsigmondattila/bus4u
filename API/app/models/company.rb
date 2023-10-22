class Company < ApplicationRecord
    has_many :admins, foreign_key: "company_uid"
    has_many :buses, foreign_key: "company_uid"
    has_many :prices, foreign_key: "company_uid"
    has_many :tickets, foreign_key: "company_uid"
end
