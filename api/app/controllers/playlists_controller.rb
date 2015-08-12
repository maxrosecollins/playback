class PlaylistsController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_filter :authenticate_user!, :except => [:show]

  def index
    @playlists = Playlist.where("user_id = ?", current_user.id).order("created_at DESC").paginate(:page => params[:page], :per_page => params[:per_page])
    render json: @playlists, :include => { :playlist_songs => { :include => :song, :only => :id  } }
  end

  def show
    #@playlist = Playlist.find(params[:id])
    @playlist = Playlist.where("user_id = ?", params[:id]).order("created_at DESC").paginate(:page => params[:page], :per_page => params[:per_page])
    render json: @playlist, :include => { :playlist_songs => { :include => :song, :only => :id  } }
  end

  def create
    @playlist = Playlist.new(params[:playlist])
    @playlist.user_id = current_user.id

    if @playlist.save
      render json: @playlist, status: :created, location: @playlist
    else
      render json: @playlist.errors, status: :unprocessable_entity
    end
  end

  def update
    @playlist = Playlist.find(params[:id])

    if @playlist.update_attributes(params[:playlist])
      render json: @playlist, status: :updated
    else
      render json: @playlist.errors, status: :unprocessable_entity
    end

  end

  def destroy
    @playlist = Playlist.find(params[:id])
    @playlist.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end

end
