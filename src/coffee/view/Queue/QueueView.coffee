class QueueView extends AppView

	el: $('#queue-container')

	list: $('#queue')

	list_entry_template: $('#queue-entry-template').html()

	artwork: $('#queue-container #artwork')

	contentWrapper: $('.main-container .wrapper')

	state: "off"

	defaultAlbumArt: 'images/white-label-blank.jpg'

	events: =>
		"click #queue .queue-entry li" : "removeFromQueue"
		"click #queue .queue-entry" : "songClicked"
		

	initialize: ->
		console.log "QueueView initialized"
		@render()

	render: ->

		# Revert to thumbnail artwork should the artwork .jpg 404 from whatever source.
		# Only bound once (important) — would cause a problem if the thumbnail also 404'd.
		$(@artwork).one('error', =>
			@useThumbnailArtwork()
		)


	appendToQueue: ->

		# Adds last song of queue into the view
		lastPos = app.queue.songs.length - 1
		lastSong = app.queue.songs[lastPos]
		if lastSong.duration
			lastSong.human_duration = lastSong.duration.toHHMMSS()
		else
			lastSong.human_duration = '—'

		@list.append( _.template(@list_entry_template, lastSong) )

	refreshQueue: ->

		# Rebuild queue markup based on queue in memory. Used after removing songs.
		@list.empty()
		i = 0
		while i < app.queue.songs.length
			@list.append( _.template(@list_entry_template, app.queue.songs[i]) )
			i++

		# Sets active song
		@updateQueue()

	toggle: (state) ->

		if Modernizr.touch == false
			if state == 'on'
				@$el.animate({'margin-left' : '0'}, 400)
				$(@contentWrapper).animate({'margin-left' : '310'}, 400)
			else
				@$el.animate({'margin-left' : '-310'}, 400)
				$(@contentWrapper).animate({'margin-left' : '0'}, 400)


	updateQueue: ->
		# Natural change (ie song ended, playing started)
		# Give target li .current-song
		# Update img

		@toggle 'on'
		queuePos = app.queue.position
		@list.children('li').removeClass('current-song')
		target = @list.children('li:eq('+queuePos+')')
		target.addClass('current-song')

	songClicked: (e) ->

		# Give target li .current-song
		# Update app.queue.position
		e.preventDefault()
		targetSong = $(e.currentTarget)
		queuePos = $(targetSong).index()
		app.view.PlayerView.skipTo(queuePos)
		@list.children('li').removeClass('current-song')
		targetSong.addClass('current-song')

	removeFromQueue: (e) ->

		e.preventDefault()
		e.stopPropagation()
		targetSong = $(e.currentTarget).parent().parent()
		index = $(targetSong).index()
		app.queue.songs.splice(index, 1)
		@updateQueuePosition(index)
		$(targetSong).remove()

	updateQueuePosition: (index)->

		# Used after app.queue.songs is spliced
		# index = index of song that was removed
		if index < app.queue.position
			app.queue.position--

	humanifySource: (src) ->

		humanSources =
			'yt' : 'YouTube',
			'sc' : 'SoundCloud',
			'ex' : 'Exfm'

		return humanSources[src]

	searchDiscogs: (query) ->

		discogs.search(query, @searchDiscogsCallback)

	getDiscogReleaseData: (release_id) ->

		discogs.getReleaseData(release_id, @discogsReleaseDataCallback)

	searchDiscogsCallback: (response) =>

		if response.data.results[0]
			releaseId = response.data.results[0].id
			console.log('best match for discogs search:', releaseId, ': querying that release now...')
			@getDiscogReleaseData(releaseId)
		else
			@useThumbnailArtwork()
			console.log 'no discogs release found.'

	discogsReleaseDataCallback: (response) =>

		if response.data.images
			#albumArt = response.data.images[0].resource_url
			albumArt = '/discogs/?url=' + response.data.images[0].resource_url
			console.log('Release found! Full release data:', response)

			# 2nd Artwork Fallback
			$(@artwork).one('error', =>
				@useThumbnailArtwork()
			)
			$(@artwork).attr 'src', albumArt

		else
			@useThumbnailArtwork()
			console.log 'no artwork found for this release.'

	useThumbnailArtwork: ->

		$(@artwork).one('error', =>
			$(@artwork).attr 'src', @defaultAlbumArt
		)

		# Fallback to thumbnail (i.e. what is displayed in search results)
		$(@artwork).attr 'src', app.queue.songs[app.queue.position].thumbnail


	markAsDeleted: (i) ->

		guilty = @list.find('.queue-entry')[i]

		track = $(guilty).find('.track')
		artist = $(guilty).find('.artist')
		time = $(guilty).find('.time')
		img = $(guilty).find('img')

		$(track).css 'opacity', 0.2
		$(artist).css 'opacity', 0.2
		$(time).css 'opacity', 0.2
		$(img).css 'opacity', 0.2
