class AddPaperclipToPost < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :image_file_name,    :string
    add_column :posts, :image_content_type, :string
    add_column :posts, :image_file_size,    :bigint
    add_column :posts, :image_updated_at,   :datetime
  end
end
