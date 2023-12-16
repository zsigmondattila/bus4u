class CreateTickets < ActiveRecord::Migration[7.0]
  def change
    create_table :tickets, id: false do |t|
      t.string :ticket_uid, primary_key: true
      t.string :company_uid
      t.string :user_uid
      t.string :ticket_type
      t.string :route_uid
      t.string :from_station_uid
      t.string :to_station_uid
      t.datetime :date_of_purchase
      t.datetime :expiration_date
      t.boolean :is_valid
      t.boolean :is_paid
      t.integer :payment_method
      t.decimal :ticket_price

      t.timestamps
    end
  end
end
