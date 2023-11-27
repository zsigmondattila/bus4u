class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments, id: false do |t|
      t.string :payment_uid, primary_key: true
      
      t.references :ticket, type: :string, foreign_key: { to_table: :tickets, primary_key: :ticket_uid }
      
      t.string :stripe_id

      t.timestamps
    end
  end
end
