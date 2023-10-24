# frozen_string_literal: true

class User < ActiveRecord::Base
  before_create :generate_uid
  
  extend Devise::Models
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  has_many :bought_tickets, foreign_key: "user_uid"

  private

  def generate_uid
    charset = ('0'..'9').to_a + ('A'..'Z').to_a
    self.user_uid = "USR_" + (1..5).map { charset.sample }.join
  end
end
