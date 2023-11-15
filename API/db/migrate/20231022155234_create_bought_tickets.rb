class CreateBoughtTickets < ActiveRecord::Migration[7.0]
  def change
    create_table :bought_tickets, id: false do |t|
      t.string :bought_ticket_uid, primary_key: true
      t.string :ticket_uid
      t.string :user_uid
      t.datetime :date_of_purchase
      t.datetime :expiration_date
      t.boolean :is_vaild

      t.timestamps
    end
  end
end
