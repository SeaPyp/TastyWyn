class ChangeWinesDescriptionToTextType < ActiveRecord::Migration[7.1]
  def up
    change_column :wines, :description, :text
  end

  def down
    change_column :wines, :description, :string
  end
end
