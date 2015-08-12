class User < ActiveRecord::Base
  require 'digest/md5'

  has_many :playlists
  has_one :history

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :gravatar_url, :history, :playlists, :username

  def gravatar_url
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(self.email.downcase)}.png"
  end

  def playlists
    Playlist.where("user_id = ?", id)
  end

  def history
    History.where("user_id = ?", id)
  end

  def as_json(options = {})
    { :id => id, :email => email, :gravatar_url => gravatar_url, :username => username }
  end

end
