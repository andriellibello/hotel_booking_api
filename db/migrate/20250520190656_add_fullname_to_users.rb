class AddFullnameToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :fullname, :string
  end
end
