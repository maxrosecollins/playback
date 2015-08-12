class PlayerView extends AppView

	el: $('#player')

	primaryButton: $('#player .playpause')

	progressBar: $('#player .seek .progress-bar')

	seekArea: $('#player .seek')

	currentTime: $('#player .current-time')

	trackDuration: $('#player .length')

	volumeContainer: $('#player .volume-container')

	volumeBar: $('#player .volume .volume-bar')

	volumeLevel: $('#player .volume .volume-level')

	volumeArea: $('#player .volume')

	volumeHandle: $('#player .volume .handle')

	initialize: ->
		console.log "PlayerView initialized"
		@exportQueueView = new ExportView()
		@render()

	events: ->

		'click .playpause' : 'playOrPause'
		'click .next' : 'skipFromClick'
		'click .prev' : 'skipFromClick'
		'click .seek' : 'moveSeekBar'
		'click .volume' : 'moveVolumeBar'

	render: ->
		#@updateSourcePlayer()
		@started = false
		@seekAreaWidth = @seekArea.width()

		#@volumeHandle.draggable
		#  axis: "y"
		#  containment: @volumeBar
		#  cursor: "hand"

		return this

	show: ->
		$(this.el).show()

	hide: ->
		$(this.el).hide()


	youtubeReady: ->
		$(this.el).children('.controls').removeClass "loading"

	youtubeError: (error) =>

		#onError:
		#https://developers.google.com/youtube/iframe_api_reference#Events
		app.view.QueueView.markAsDeleted(app.queue.position)
		@skip('forwards')

	youtubeStateChange: (state) =>
		###
		-1 (unstarted)
		0 (ended)
		1 (playing)
		2 (paused)
		3 (buffering)
		5 (video cued).
		###
		console.log 'youtube player state:', state.data
		if state.data == 0
			@skip("forwards")

		if state.data == 1
			#Populate Track Duration
			@trackDuration.html(@sourcePlayer.player.getDuration().toHHMMSS())

	updatePlayerState: (state) =>

		@primaryButton.removeClass("paused").removeClass("playing").removeClass("buffering")
		@primaryButton.addClass state

		$(this.el).children('.controls').children('.track').html(app.queue.songs[app.queue.position].title)

	playOrPause: (e) ->

		if e
			e.preventDefault()
			element = $(e.currentTarget)
		else
			element = $('.playpause')

		if app.queue.songs.length == 0
			return

		if element.hasClass "paused"
			@play()
		else
			@pause()


	play: ->

		_gaq.push(['_trackEvent', 'Player', 'Play', app.queue.songs[app.queue.position].title]);

		# Send play to account history is user is logged in
		if localStorage.getItem('user') != null
			song_played = new RecordHistory()
			current_song = app.queue.songs[app.queue.position]
			song_played.set(song : {
				"duration": current_song.duration, # seconds
				"source": current_song.source, # yt, sc, ex
				"source_id": current_song.id, # e.g. yt 93ASUImTedo
				"title": current_song.title # e.g. Disclosure - Latch
				"thumbnail" : current_song.thumbnail
			})
			song_played.save(song_played.attributes, {
				success: (model, response, options) =>
					#console.log 'successfully recorded song play.'
					#console.log model, response, options
				error: (model, xhr, options) =>
					#console.log 'failed to record song play.'
					#console.log model, xhr, options
			})

		@updatePlayerState "buffering"

		app.view.QueueView.updateQueue()
		@updateSourcePlayer()

		queuePos = app.queue.position
		id = app.queue.songs[queuePos].id
		source = app.queue.songs[queuePos].source

		#Reset the seekbar to zero
		@resetSeekBar()

		if id == @lastPlayedID
			console.log "Gonna resume"
			@resume()
			return

		if Modernizr.touch == true
			console.log "Swapping mobile <audio> src.."
			#ex_player.src = app.queue.songs[queuePos].id
			exfmPlay(app.queue.songs[queuePos].id);
		else
			method = @sourcePlayer.load
			console.log "Attempting to play from "+source+" player:", @sourcePlayer.player, "[song id: "+id+"]"
			if typeof(method) == "function"
				method(id)
			else
				@sourcePlayer.player[method](id)

		@lastPlayedID = id

		if @started == false
			@started = true

		@updatePlayerState "playing"


		clearInterval(@seekTimer)

		#each 500ms update the width of seek-bar and current time text
		@seekTimer = setInterval(=>
			@updatePlayer()
		, 500)


		# Tell QueueView to go grab metadata
		app.view.QueueView.searchDiscogs(app.queue.songs[app.queue.position].title)

		# If we want to animate the album art change, this is the place to invoke it

	resume: ->
		app.view.QueueView.updateQueue()
		method = @sourcePlayer.play
		console.log "Attempting to resume this player:", @sourcePlayer.player


		_gaq.push(['_trackEvent', 'Player', 'Resume', app.queue.songs[app.queue.position].title]);

		if typeof(method) == "function"
			method()
		else
			@sourcePlayer.player[method]()

		@updatePlayerState "playing"

		clearInterval(@seekTimer)

		#each 500ms update the width of seek-bar and current time text
		@seekTimer = setInterval(=>
			@updatePlayer()
		, 500)

	pause: ->

		_gaq.push(['_trackEvent', 'Player', 'Pause', app.queue.songs[app.queue.position].title]);

		method = @sourcePlayer.pause

		if Modernizr.touch == true
			ex_player.pause()
		else
			console.log "Attempting to pause current player [", @sourcePlayer.player, "]"
			if typeof(method) == "function"
				method()
			else
				@sourcePlayer.player[method]()

		clearInterval(@seekTimer)

		@updatePlayerState "paused"

	skipFromClick: (e) =>
		e.preventDefault()
		direction = $(e.currentTarget).attr("data-skip-direction")
		@skip(direction);

	skip: (direction) =>

		_gaq.push(['_trackEvent', 'Queue', 'Skip', direction]);

		if @started == false and app.queue.songs[0]?
			@play()
			return

		switch (direction)
			when "forwards"
				if app.queue.songs[app.queue.position+1]?
					app.queue.position = app.queue.position+1
				else
					clearTimeout(@seekTimer)
					console.log "Cannot skip forwards: no more songs queued."
					@pause()
					return;
			when "backwards"
				if app.queue.songs[app.queue.position-1]?
					app.queue.position = app.queue.position-1
				else
					console.log "Cannot skip backwards: no more songs queued."
					return;

		@pause()
		@play() #will grab the new song by itself

	skipTo: (position) ->

		app.queue.position = position
		@pause()
		@play()

	seekTo: (seconds) =>

		_gaq.push(['_trackEvent', 'Player', 'Seek', seconds]);

		@pendingSeek = seconds

		queuePos = app.queue.position
		source = app.queue.songs[queuePos].source

		if Modernizr.touch == true
			ex_player.currentTime = seconds
		else
			method = @sourcePlayer.seek

			if typeof(method) == "function"
				method(seconds)
			else
				@sourcePlayer.player[method](seconds)

	moveSeekBar: (e) ->

		PosAsPercent = Math.round(((e.pageX - @seekArea.offset().left) / @seekAreaWidth)*100)
		@progressBar.width(PosAsPercent+"%")

		if @sourcePlayer.name == "ex"
			@seekTo (ex_player.duration/100) * PosAsPercent
		else
			@seekTo (@sourcePlayer.player.getDuration()/100) * PosAsPercent

	moveVolumeBar: (e) ->

		percent = e.offsetY

		if percent <= 10
			percent = 0
		else if percent > 10
			percent = (percent - 10)
		else if percent > 110
			percent = 100

		@volumeLevel.css 'height', Math.round((100 - percent))
		@volumeBar.css 'height', Math.round((100 - percent))
		@volumeBar.css 'padding-top', Math.round(percent)

		#console.log "Handle top:" + @volumeHandle.css 'top'
		#console.log "Handle top:" + app.view.PlayerView.volumeHandle.css 'top'


		@setVolume((100 - percent))

		percent = null

	updatePlayer: ->

		#Work out the curent time as a percentage of the duration

		if @sourcePlayer.name == "sc"

			#Cancel the current update if song is still buffering (and threfore scPlayer isnt fully init) — seek bar can wait a sec.
			if scPlayer == null
				return
			currentTime = @sourcePlayer.player.getCurrentTime()
			currentDuration = @sourcePlayer.player.getDuration()

			if scPlayer.soundObject and scPlayer.soundObject.playState == 0
				@skip("forwards")

		else if @sourcePlayer.name == "ex"

			currentTime = ex_player.currentTime
			currentDuration = ex_player.duration

		else

			currentTime = @sourcePlayer.player.getCurrentTime()
			currentDuration = @sourcePlayer.player.getDuration()

		@updateSeekBar(currentTime, currentDuration)


	updateSeekBar: (currentTime, currentDuration) ->

		#both values are in seconds

		if @pendingSeek != null
			currentTime = @pendingSeek
			@pendingSeek = null

		progressPercentage = ((currentTime / currentDuration)*100)
		#set the width of progressBar to the percentage
		if progressPercentage < 100
			@progressBar.width(progressPercentage+"%")

		#update the current time displayed.
		if currentTime
			@currentTime.html(currentTime.toHHMMSS())


	resetSeekBar: (e) ->
		@progressBar.width("0%")

	getVolume: () ->
		method = @sourcePlayer.getVolume

		if typeof(method) == "function"
			return method()
		else
			return @sourcePlayer.player[method]()

	setVolume: (volume) ->
		method = @sourcePlayer.setVolume

		if typeof(method) == "function"
			return method(volume)
		else
			return @sourcePlayer.player[method](volume)

	updateSourcePlayer: ->
		queuePos = app.queue.position
		source = app.queue.songs[queuePos].source
		@sourcePlayer = @sourcePlayerMap source

	sourcePlayerMap: (source)->

		sourceMap =
			"yt" :
				"name" : "yt"
				"player" : yt_player
				"load" : "loadVideoById"
				"play" : "playVideo"
				"pause" : "pauseVideo"
				"seek" : "seekTo" #seconds
				"mute" : "mute"
				"unmute" : "unMute"
				"setVolume" : "setVolume" # 0 - 100
				"getVolume" : "getVolume" # 0 - 100
				"getPlaybackRate" : "getPlaybackRate"
				"setPlaybackRate" : "setPlaybackRate"
				"getAvailableQualityLevels" : "getAvailableQualityLevels"
				"getPlaybackQuality" : "getPlaybackQuality"
				"setPlaybackQuality" : "setPlaybackQuality"
				"getVideoLoadedFraction" : "getVideoLoadedFraction"
				"getPlayerState" : "getPlayerState"
				"getCurrentTime" : "getCurrentTime"
				"getDuration" : "getDuration"
				"getVideoUrl" : "getVideoUrl"
			"sc" :
				"name" : "sc"
				"player" : scPlayer
				"load" : scPlayer.load
				"play" : scPlayer.play
				"pause" : scPlayer.pause
				"seek" : scPlayer.seekTo # milliseconds
				"getVolume" : scPlayer.getVolume #  0 - 100
				"setVolume" : scPlayer.setVolume # 0 - 100
				"getDuration" : scPlayer.getDuration # milliseconds
				"getCurrentTime" : scPlayer.getCurrentTime # milliseconds
			"ex" :
				"name" : "ex"
				"player" : ex_player
				"load" : exfmPlay
				"play" : exFmPlay
				"pause" : "pause"
				"seek" : exFmSeek
				"getVolume" : exFmGetVolume # 0 - 100
				"setVolume" : exFmSetVolume # 0 - 100
				"getDuration" : exFmGetDuration
				"getCurrentTime" : exFmGetCurrentTime

		if source == "yt"
			return sourceMap.yt
		else if source == "sc"
			return sourceMap.sc
		else if source == "ex"
			return sourceMap.ex
		else
			return null