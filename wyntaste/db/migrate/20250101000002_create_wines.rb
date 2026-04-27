class CreateWines < ActiveRecord::Migration[8.1]
  def change
    create_table :wines do |t|
      t.string :name, null: false
      t.string :varietal
      t.integer :vintage
      t.string :origin
      t.text :description

      t.timestamps
    end
  end
end
