class CreateRoutes < ActiveRecord::Migration[7.0]
  def change
    create_table :routes, id: false do |t|
      t.string :route_uid, primary_key: true
      t.string :company_uid
      t.string :name
      t.integer :nr_of_stations
      t.decimal :basic_fare
      
      t.timestamps
    end
  end
end
