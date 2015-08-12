class PlaylistSongController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_filter :authenticate_user!

  def show
    @playlist_song = PlaylistSong.find(params[:id])
    render json: @playlist_song
  end

  def create
    @playlist = Playlist.find(params[:playlist_id])
    @song = Song.new(params[:song])
    @order = params[:order]
    @playlist_song = PlaylistSong.new
    @playlist_song.playlist = @playlist
    @playlist_song.song = @song
    @playlist_song.order = @order

    if @playlist_song.save
      render json: @playlist_song, status: :created, location: @playlist_song
    else
      render json: @playlist_song.errors, status: :unprocessable_entity
    end
  end

  def update
    @playlist_song = PlaylistSong.find(params[:id])

    if @playlist_song.update_attributes(params[:playlist_song])
      render json: @playlist_song, status: :updated
    else
      render json: @playlist_song.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @playlist_song = PlaylistSong.find(params[:id])
    @playlist_song.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end

end
