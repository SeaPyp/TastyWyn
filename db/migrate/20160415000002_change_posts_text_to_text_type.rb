class ChangePostsTextToTextType < ActiveRecord::Migration
  def up
    change_column :posts, :text, :text
  end

  def down
    change_column :posts, :text, :string
  end
end
