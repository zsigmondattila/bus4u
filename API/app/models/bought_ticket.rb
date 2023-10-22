class BoughtTicket < ApplicationRecord
    belongs_to :ticket, foreign_key: "ticket_uid"
    belongs_to :user, foreign_key: "user_uid"
end
