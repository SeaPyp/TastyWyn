class AddLastNameToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :last_name, :string
    rename_column :users, :name, :first_name
  end
end
