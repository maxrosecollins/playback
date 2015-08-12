class PlaylistsView extends AppView

	el: $('#user_view #saved-playlists')

	name: 'playlists'

	template: $('#saved-playlists-template').html()

	initialize: ->
		console.log "PlaylistsView initialized"
		@el = $('#user_view #saved-playlists')
		@render()

	render: ->

		@el = $('#user_view #saved-playlists')

		locally_stored_user = JSON.parse(localStorage.getItem 'user')

		if app.view and app.view.ContentView.userView.is_public == true and app.user.id != locally_stored_user.id
			@el.html _.template(@template, { playlists : app.playlists })
			@el.show()
		else
			@localstoragePlaylists = localStorage.getItem 'playlists'
			if @localstoragePlaylists != null
				app.playlists = JSON.parse(@localstoragePlaylists)
				@el.html _.template(@template, { playlists : app.playlists })
				@el.show()
			else
				playlists = new Playlists()
				playlists.url = '/playlists/'
				playlists.fetch(
					success: (model, response, options) =>
						#localStorage.setItem 'playlists', JSON.stringify(response)
						app.playlists = response
						@render()
					error: (model, xhr, options) =>
						#console.log 'failed to grab play someone else\'s playlists.'
						#console.log model, xhr, options
				)
		
	show: ->

		@el = $('#user_view #saved-playlists')
		console.log 'playlists view showing..', @el.length

		@render()
		@el.show()
		

	hide: ->

		@el.hide()