class CreateLines < ActiveRecord::Migration
  def change
    create_table :lines do |t|
      t.datetime :date
      t.string :team1
      t.string :team2
      t.decimal :over_under
      t.decimal :team1_line
      t.decimal :team2_line
      t.string :sport
      t.string :linetype

      t.timestamps
    end
  end
end
