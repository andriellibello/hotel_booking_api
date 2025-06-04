class AddUniqueIndexToRoomsNumber < ActiveRecord::Migration[7.1]
  def change
    add_index :rooms, :number, unique: true
  end
end
