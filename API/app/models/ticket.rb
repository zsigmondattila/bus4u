class Ticket < ApplicationRecord
    before_create :generate_uid
    
    belongs_to :company, foreign_key: "company_uid"
    has_many :bought_tickets, foreign_key: "ticket_uid"

    private

  def generate_uid
    charset = ('0'..'9').to_a + ('A'..'Z').to_a
    self.ticket_uid = "TIC_" + (1..5).map { charset.sample }.join
  end
end
