class CreateHistories < ActiveRecord::Migration
  def change
    create_table :histories do |t|
      t.references :song
      t.references :user

      t.timestamps
    end
    add_index :histories, :song_id
    add_index :histories, :user_id
  end
end
