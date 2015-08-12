Api::Application.routes.draw do

    devise_for :users, :controllers => {:sessions => "sessions", registrations: "registrations", users: "users"}

    resources :users, :only => [:show, :update]

  	resources :history #history.json includes songs.

    resources :playlists, :shallow => true do
  		resources :song
	end

	resources :playlist_song #for creating etc.

	resources :song #for creating etc.

end
