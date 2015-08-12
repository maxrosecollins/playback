class SongController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_filter :authenticate_user!

  def index
    @song = Song.all()
    render json: @song
  end

  def show
    @song = Song.find(params[:id])
    render json: @song
  end

  def create

    @song = Song.new(params[:playlist])

    if @song.save
      render json: @song, status: :created, location: @song
    else
      render json: @song.errors, status: :unprocessable_entity
    end

  end

  def update

    @song = Song.find(params[:id])

    if @song.update_attributes(params[:song])
      render json: @song, status: :updated
    else
      render json: @song.errors, status: :unprocessable_entity
    end

  end

end

