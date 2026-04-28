class CreateWines < ActiveRecord::Migration[7.1]
  def change
    create_table :wines do |t|
      t.string :name
      t.string :varietal
      t.integer :vintage
      t.string :origin
      t.string :description

      t.timestamps null: false
    end
  end
end
