class CreateBuses < ActiveRecord::Migration[7.0]
  def change
    create_table :buses, id: false do |t|
      t.string :bus_uid, primary_key: true
      t.string :company_uid
      t.string :string
      t.string :license_plate
      t.string :brand
      t.integer :manufacturing_year
      t.integer :capacity
      t.datetime :road_tax
      t.datetime :insurance
      t.datetime :technical_exam

      t.timestamps
    end
  end
end
