class ChangePostsTextToTextType < ActiveRecord::Migration[7.1]
  def up
    change_column :posts, :text, :text
  end

  def down
    change_column :posts, :text, :string
  end
end
