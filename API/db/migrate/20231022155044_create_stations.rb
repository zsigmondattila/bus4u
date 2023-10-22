class CreateStations < ActiveRecord::Migration[7.0]
  def change
    create_table :stations, id: false do |t|
      t.string :station_uid, primary_key: true
      t.string :name
      t.decimal :longitude
      t.decimal :latitude
      t.string :city
      t.string :address

      t.timestamps
    end
  end
end
