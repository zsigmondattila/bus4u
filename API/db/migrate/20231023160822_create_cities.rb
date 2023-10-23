class CreateCities < ActiveRecord::Migration[7.0]
  def change
    create_table :cities, id: false do |t|
      t.string :city_uid, primary_key: true
      t.string :name
      t.string :zip_code

      t.timestamps
    end
  end
end
