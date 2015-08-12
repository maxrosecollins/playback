class ExportView extends AppView

	el: $('.export')

	menu_template: $('#export-queue-template').html()

	events:
		"click" : "checkForUser"
		"mouseover" : "showDropdown"
		"mouseout .export-menu" : "hideDropdown"
		"click .new" : "displayNewPlaylistForm"
		"submit .new-playlist-form form" : "createNewPlaylist"

	initialize: ->
		console.log "ExportQueueView initialized"
		if app.user != null
			@loadPlaylists()

	render: (playlists) ->
		@$el.css 'display', "block"
		app.view.PlayerView.seekArea.css 'right', '225px'
		@$el.find('.export-menu').html(_.template(@menu_template, {playlists : playlists}))
		bottom_value = 125 + (29*playlists.length)
		if bottom_value > 295
			bottom_value = 295
		$(@$el.find('.export-menu')).css 'bottom', bottom_value

	checkForUser: ->
		# If user is not logged in, dropdown won't appear, so they may try to click, in which case, lets send them to login.
		if app.user == null
			app.router.navigate 'login', true

	showDropdown: (e) ->
		if app.user != null
			@$el.find('.export-menu').removeClass 'hidden'

	hideDropdown: (e) ->
		@$el.find('.export-menu').addClass 'hidden'

	displayNewPlaylistForm: (e) ->

		# show form
		if e
			e.preventDefault()
		@$el.find('.new').hide()
		@$el.find('.new-playlist-form').show()


	hideNewPlaylistForm: ->

		@$el.find('.new-playlist-form').hide()
		@$el.find('.new').show()

	createNewPlaylist: (e) ->

		e.preventDefault()

		input = $(e.currentTarget).find('input')
		title = $(input).val()

		if title != ""

			@$el.find('.new').hide()

			playlist = new Playlists()

			#reformat songs to suit backend
			songs = app.queue.songs
			i = 0
			while i < songs.length
				songs[i].source_id = songs[i].id
				delete songs[i].id
				delete songs[i].human_duration
				i++


			playlist.set 'playlist', { 'title' : title, 'songs_attributes' : songs}

			playlist.save(playlist.attributes,
				success: (model, response, options) =>
					console.log 'successfully saved playlist.'
					@loadPlaylists()
					#console.log model, response, options
				error: (model, xhr, options) =>
					#console.log 'failed to record song play.'
					#console.log model, xhr, options)
			)



