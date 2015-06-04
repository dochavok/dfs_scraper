class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.integer :projection_id
      t.string :sport
      t.text :date
      t.string :position
      t.string :team
      t.string :player
      t.integer :salary
      t.string :site
      t.integer :site_id
      t.integer :salary_cap
      t.string :format

      t.timestamps
    end
  end
end
