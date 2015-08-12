class AppView extends Backbone.View

	el : $('body')

	initialize: ->
		console.log "AppView initialized"

		@HeaderView = new HeaderView()
		@QueueView = new QueueView()
		@PlayerView = new PlayerView()
		@ContentView = new ContentView()
		@ModalView = new ModalView()

		# Globally bind keyboard shortcuts.
		$(window).keydown( (e) ->

			target = e.target || e.srcElement
			if target.tagName != 'INPUT' # Disable these shortcuts if user is inside an <input>.

				if e.keyCode == 27 # Esc : hide modals
					app.view.ModalView.hide()
				else if e.keyCode == 32 # Spacebar: play/pause
					e.preventDefault()
					app.view.PlayerView.playOrPause()
				else if e.keyCode == 37 # Left arrow: skip backward
					e.preventDefault()
					app.view.PlayerView.skip("backwards")
				else if e.keyCode == 39 # Right arrow: skip forward
					e.preventDefault()
					app.view.PlayerView.skip("forwards")
		)

	render: ->
		if environment == "debug"
			$(this.el).addClass "debug-mode"

	events: ->
		if (Modernizr.touch == true)
			# Touch events
		else
			# Standard events


	switchContext: (e) ->
		window.app.router.navigate($(e.currentTarget).data('target'), true)

	show: ->
		@$el.show()

	hide: ->
		@$el.hide()

	loadPlaylists: ->

		# Load playlists
		playlists = new Playlists()
		playlists.fetch(
			success: (model, response, options) =>
				localStorage.setItem 'playlists', JSON.stringify(response)
				app.view.PlayerView.exportQueueView.render(response)
			error: (model, xhr, options) =>
				console.log 'failed to grab play histories.'
				console.log model, xhr, options
		)

