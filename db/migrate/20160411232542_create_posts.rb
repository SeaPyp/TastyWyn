class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.string :title
      t.string :text
      t.string :image
      t.integer :rating
      t.references :user, index: true, foreign_key: true
      t.references :wine, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
