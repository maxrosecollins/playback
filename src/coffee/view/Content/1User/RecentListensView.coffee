class RecentListensView extends AppView

	name: 'recent-listens'

	template: $('#recent-listens-template').html()

	recentListens : null

	events:
		"click #recent-listens .col a" : "queueSong"

	initialize: ->
		console.log "RecentListensView initialized"
		@render()

	render: ->

		@el = $('#user_view #recent-listens')

		if @recentListens == null
			@recentListens = new Histories()

		# Loading state would be nice.

		@recentListens.fetch(
			success: (model, response, options) =>

				#console.log response
				@el.html _.template(@template, {songs : response})


			error: (model, xhr, options) =>
				console.log 'failed to grab play histories.'
				console.log model, xhr, options
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

		