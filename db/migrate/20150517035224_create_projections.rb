class CreateProjections < ActiveRecord::Migration
  def change
    create_table :projections do |t|
      t.datetime :date
      t.string :player
      t.decimal :fpts
      t.string :team
      t.string :opponent
      t.string :position
      t.integer :cost
      t.string :source
      t.string :site
      t.string :sport

      t.timestamps
    end
  end
end
