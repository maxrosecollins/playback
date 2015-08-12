class UsersController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_filter :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    params[:user] ||= {:id => params[:id],:username => params[:username]}

    @user = User.find(current_user.id)
    if @user.update_attributes(params[:user])
      # Sign in the user by passing validation in case his password changed
      sign_in @user, :bypass => true
      #render :json => {:success => true, "message" => :"Profile updated."}
      render :json => @user
    else
      render :json => {:success => false, "errors" => @user.errors}
    end
  end

  def show
    @user = User.where("username = ?", params[:id])
    render json: @user
  end

end