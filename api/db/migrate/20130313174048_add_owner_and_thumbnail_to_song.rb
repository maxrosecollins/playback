class AddOwnerAndThumbnailToSong < ActiveRecord::Migration
  def change
    add_column :songs, :owner, :string
    add_column :songs, :thumbnail, :string
  end
end
