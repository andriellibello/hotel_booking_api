class CreateRooms < ActiveRecord::Migration[7.1]
  def change
    create_table :rooms do |t|
      t.integer :number
      t.text :description
      t.integer :capacity
      t.decimal :price

      t.timestamps
    end
  end
end
