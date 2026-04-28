class AddUserIdToWines < ActiveRecord::Migration[7.1]
  def change
    add_column :wines, :user_id, :integer
    add_index :wines, :user_id
    add_foreign_key :wines, :users
  end
end
