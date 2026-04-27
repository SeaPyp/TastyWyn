class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text :text, null: false
      t.integer :rating
      t.bigint :user_id, null: false
      t.bigint :wine_id, null: false

      t.timestamps
    end

    add_index :posts, :user_id
    add_index :posts, :wine_id
    add_foreign_key :posts, :users
    add_foreign_key :posts, :wines
  end
end
