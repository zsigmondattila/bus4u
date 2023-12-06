class CreateTimetables < ActiveRecord::Migration[7.0]
  def change
    create_table :timetables, id: false do |t|
      t.string :timetable_uid, primary_key: true
      t.string :route_station_uid
      t.datetime :departure_time
      t.decimal :fare
      t.string :name

      t.timestamps
    end
  end
end
