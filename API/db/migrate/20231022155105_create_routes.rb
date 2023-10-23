class CreateRoutes < ActiveRecord::Migration[7.0]
  def change
    create_table :routes, id: false do |t|
      t.string :route_uid, primary_key: true
      t.string :name
      
      t.timestamps
    end
  end
end
