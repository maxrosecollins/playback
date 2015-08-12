class AddSourceIdToSong < ActiveRecord::Migration
  def change
    add_column :songs, :source_id, :string
  end
end
