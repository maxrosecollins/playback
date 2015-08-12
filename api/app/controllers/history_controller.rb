class HistoryController < ApplicationController

	before_filter :authenticate_user!

  def index
    @history = History.where("user_id = ?", current_user.id).order("created_at DESC").paginate(:page => params[:page], :per_page => 20)
    render json: @history, :include => :song
  end

  def show
    @history = History.where("user_id = ?", params[:id]).order("created_at DESC").paginate(:page => params[:page], :per_page => 20)
    render json: @history, :include => :song
  end

  def create
    @song = Song.new(params[:song])

    @history = History.new

    @songs = Song.where("source_id = ?", @song.source_id)

    if @songs.count == 0
      @song.save
      @history.song = @song
    elsif @songs.count == 1
      @history.song = @songs.first
    end

    @history.user = current_user

    if @history.save
      render json: {:success => true}, status: :created, location: @history
    else
      render json: @history.errors, status: :unprocessable_entity
    end
  end

end
