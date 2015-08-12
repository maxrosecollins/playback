class SinglePlaylistView extends AppView

	name: 'playlist'

	#el: null

	template: $('#single-playlist-template').html()

	initialize: ->
		console.log "SinglePlaylistView initialized"
		@el = $('#user_view #single-playlist')
		#@render()

	events:
		"click #playlist-single .options a" : "queueSong"
		"click a.queue-all" : "queuePlaylist"

	render: (id) ->

		@el = $('#user_view #single-playlist')

		selected_playlist = null

		i = 0
		while i < app.playlists.length
			if app.playlists[i].id == parseInt(id,10)
				selected_playlist = app.playlists[i]
				@playlist_songs = selected_playlist.playlist_songs
			i++

		@el.html _.template(@template, {playlist : selected_playlist})
		
		@show()

	queueSong: (e, song) ->

		e.preventDefault()

		if app.queue.songs.length == 0
			autoPlay = true

		if song
			source = song.source
			id = song.source_id
			title = song.title
			thumbnail = song.thumbnail
			owner = song.owner
			duration = song.duration
		else
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

	queuePlaylist: (e) ->

		e.preventDefault()
		console.log @playlist_songs
		i = 0
		while i < @playlist_songs.length
			@queueSong(e, @playlist_songs[i].song)
			i++
		
	show: ->

		@el.show()

	hide: ->

		@el.hide()