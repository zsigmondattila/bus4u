class CreateCompanyStations < ActiveRecord::Migration[7.0]
  def change
    create_table :company_stations, id: false do |t|
      t.string :company_station_uid, primary_key: true
      t.timestamps
    end
  end
end
