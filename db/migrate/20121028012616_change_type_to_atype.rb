class ChangeTypeToAtype < ActiveRecord::Migration
  def up
    rename_column :stations, :type, :station_type
  end

  def down
  end
end
