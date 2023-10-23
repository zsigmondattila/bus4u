class CreateRouteStations < ActiveRecord::Migration[7.0]
  def change
    create_table :route_stations, id: false do |t|
      t.string :route_station_uid, primary_key: true
      t.string :station_uid
      t.string :company_uid
      t.string :route_uid
      t.datetime :departure_time
      t.integer :sequence

      t.timestamps
    end
  end
end
