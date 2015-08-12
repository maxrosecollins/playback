class ProfileSummaryView extends AppView

	name: 'profile-summary'

	el: $('#profile-summary')

	savedPlaylistsTemplate: $('#saved-playlists-template').html()

	recentListensTemplate: $('#recent-listens-template').html()

	recentListens : null

	initialize: ->
		console.log "ProfileSummaryView initialized"
		

	render: -> # Loading states would be nice in future.

		@el = $('#user_view #profile-summary')
		@recentListensEl = @el.find('.module.recent-listens')
		@savedPlaylistsEl = @el.find('.module.saved-playlists')

		locally_stored_user = JSON.parse(localStorage.getItem 'user')

		if app.view and app.view.ContentView.userView.is_public == true and app.user.id != locally_stored_user.id
			@savedPlaylistsEl.html _.template(@savedPlaylistsTemplate, {playlists : app.playlists, summary : true})
			@savedPlaylistsEl.show()
		else
			@localstoragePlaylists = localStorage.getItem 'playlists'
			if @localstoragePlaylists != null
				playlists = JSON.parse(@localstoragePlaylists)
				@savedPlaylistsEl.html _.template(@savedPlaylistsTemplate, {playlists : playlists, summary : true})
				@savedPlaylistsEl.show()


		if app.user
			histories = new Histories()
			histories.url = '/history/' + app.user.id
			histories.fetch(
				success: (model, response, options) =>
					@recentListensEl.html _.template(@recentListensTemplate, {songs : response, summary : true})

					$('.recent-listens .col a').click( (e) =>
						@queueSong(e)
					)
				error: (model, xhr, options) =>
					#console.log 'failed to grab play someone else\'s playlists.'
					#console.log model, xhr, options
			)
		
		

	queueSong: (e) ->

		e.preventDefault()

		if app.queue.songs.length == 0
			autoPlay = true

		a = $(e.currentTarget)
		source = a.attr 'data-source'
		id = a.attr 'data-id'
		title = a.attr 'data-title'
		thumbnail = a.attr 'data-thumbnail'
		owner = a.attr 'data-owner'
		duration = a.attr 'data-duration'

		_gaq.push(['_trackEvent', 'Queue', 'add', title]);

		song =
			"source" : source
			"id" : id
			"title" : title
			"owner" : owner
			"thumbnail" : thumbnail
			"duration" : duration

		app.queue.songs.push song
		app.view.QueueView.appendToQueue()

		if autoPlay == true
			app.view.PlayerView.play()

	show: ->

		@render()
		@el.show()

	hide: ->

		@el.hide()

		