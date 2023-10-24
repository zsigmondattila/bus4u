class CreateTickets < ActiveRecord::Migration[7.0]
  def change
    create_table :tickets, id: false do |t|
      t.string :ticket_uid, primary_key: true
      t.string :company_uid
      t.string :type
      t.string :price_uid

      t.timestamps
    end
  end
end
