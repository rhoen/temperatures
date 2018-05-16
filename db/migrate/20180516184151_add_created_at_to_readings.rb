class AddCreatedAtToReadings < ActiveRecord::Migration[5.2]
  def change
    add_column :readings, :created_at, :datetime
  end
end
