class CreateStations < ActiveRecord::Migration
  def change
    create_table :stations do |t|
      t.string :type
      t.string :name
      t.float :lat
      t.float :long

      t.timestamps
    end
  end
end
