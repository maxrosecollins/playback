class Playlist < ActiveRecord::Base
  has_many :playlist_songs

  has_many :songs, :through => :playlist_songs
  accepts_nested_attributes_for :songs

  belongs_to :user

  attr_accessible :user, :title, :songs_attributes, :duration

  def duration
  	self.songs.sum('duration')  	
  end

end
