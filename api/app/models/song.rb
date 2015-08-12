class Song < ActiveRecord::Base

    has_and_belongs_to_many :playlist_songs
    has_many :history
    has_many :playlists, :through => :playlist_songs


    attr_accessible :duration, :source, :title, :source_id, :playlist, :global_listens, :user_listens, :thumbnail, :owner

    #def user_listens(user_id)
    #    self.histories.user
    #end

    def save(options = {})
        @song = Song.where("source_id = ?", self.source_id)
        if @song.count == 0
            super(options = {})  
        elsif @song.count == 1
            self.id = @song.first.id
            return true
        end
    end

    def global_listens
        self.history.count
    end

    def as_json(options = {})
        { :id => id, :duration => duration, :source => source, :source_id => source_id, :title => title, :thumbnail => thumbnail, :owner => owner}
    end
end
