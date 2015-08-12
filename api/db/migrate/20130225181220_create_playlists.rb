class CreatePlaylists < ActiveRecord::Migration
  def change
    create_table :playlists do |t|
      t.text :title
      t.references :user

      t.timestamps
    end
    add_index :playlists, :user_id
  end
end
