class PlaylistSong < ActiveRecord::Base
  belongs_to :song
  belongs_to :playlist
  accepts_nested_attributes_for :song
  attr_accessible :order, :playlist, :playlist_id, :song
end
