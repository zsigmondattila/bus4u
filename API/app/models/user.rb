class User < ActiveRecord::Base
  before_create :generate_uid
  validates :stripe_id, presence: true 
  before_validation :create_on_stripe, on: :create
  
  extend Devise::Models
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  has_many :tickets, foreign_key: "uid"

  private

  def generate_uid
    charset = ('0'..'9').to_a + ('A'..'Z').to_a
    self.uid = "USR_" + (1..5).map { charset.sample }.join
  end

  def create_on_stripe
    params = { email: email}
    response = Stripe::Customer.create(params)
    self.stripe_id = response.id
  end
end
