class Ticket < ApplicationRecord
    belongs_to :company, foreign_key: "company_uid"
    belongs_to :price, foreign_key: "price_uid"
    has_many :bought_tickets, foreign_key: "ticket_uid"
end
