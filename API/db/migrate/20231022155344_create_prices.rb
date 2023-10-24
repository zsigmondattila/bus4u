class CreatePrices < ActiveRecord::Migration[7.0]
  def change
    create_table :prices, id: false do |t|
      t.string :price_uid, primary_key: true
      t.string :route_uid
      t.string :from_station_uid
      t.string :to_station_uid
      t.decimal :ticket_price

      t.timestamps
    end
  end
end
