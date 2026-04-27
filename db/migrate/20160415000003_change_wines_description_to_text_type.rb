class ChangeWinesDescriptionToTextType < ActiveRecord::Migration
  def up
    change_column :wines, :description, :text
  end

  def down
    change_column :wines, :description, :string
  end
end
