class CreatePlaylistSong < ActiveRecord::Migration
  def change
    create_table :playlist_song do |t|
      t.references :playlist, :null => false
      t.references :song, :null => false
      t.integer :order

      t.timestamps
    end
    add_index :playlist_song, :playlist_id
    add_index :playlist_song, :song_id
  end
end
