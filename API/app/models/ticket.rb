class Ticket < ApplicationRecord
    before_create :generate_uid

    attr_accessor :credit_card_number, :credit_card_exp_month, :credit_card_exp_year, :credit_card_cvv
    
    belongs_to :company, foreign_key: "company_uid"
    belongs_to :user, foreign_key: "user_uid"
    has_one :payment

    after_create :create_payment

    enum payment_method: %i[credit_card]

  private

  def generate_uid
    charset = ('0'..'9').to_a + ('A'..'Z').to_a
    self.ticket_uid = "TIC_" + (1..5).map { charset.sample }.join
  end

  def create_payment
    params = {
      ticket_id: ticket_uid,
      credit_card_number: credit_card_number,
      credit_card_exp_month: credit_card_exp_month,
      credit_card_exp_year: credit_card_exp_year,
      credit_card_cvv: credit_card_cvv
    }
    Payment.create!(params)
  end
end
