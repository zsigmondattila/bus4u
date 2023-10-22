class BoughtTicket < ApplicationRecord
    before_create :generate_uid
    
    belongs_to :ticket, foreign_key: "ticket_uid"
    belongs_to :user, foreign_key: "user_uid"

    private

  def generate_uid
    charset = ('0'..'9').to_a + ('A'..'Z').to_a
    self.bought_ticket_uid = "BTI_" + (1..5).map { charset.sample }.join
  end
end
