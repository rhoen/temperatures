class CreateReadings < ActiveRecord::Migration[5.2]
  def change
    create_table :readings do |t|
      t.float :temperature
      t.integer :device_id
      t.string :location
    end
  end
end
