class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.text :title
      t.string :source
      t.integer :duration

      t.timestamps
    end
  end
end
