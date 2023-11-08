class Company < ApplicationRecord
    before_create :generate_uid
    
    has_many :admins, foreign_key: "company_uid"
    has_many :buses, foreign_key: "company_uid"
    has_many :tickets, foreign_key: "company_uid"
    has_many :stations_companies
    has_many :stations, through: :stations_companies
    has_many :routes, foreign_key: "company_uid"

    private

  def generate_uid
    charset = ('0'..'9').to_a + ('A'..'Z').to_a
    self.company_uid = "CPY_" + (1..5).map { charset.sample }.join
  end
end
