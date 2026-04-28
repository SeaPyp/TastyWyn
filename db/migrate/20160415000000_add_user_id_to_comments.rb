class AddUserIdToComments < ActiveRecord::Migration[7.1]
  def change
    add_column :comments, :user_id, :integer
    add_index :comments, :user_id
    add_foreign_key :comments, :users
  end
end
