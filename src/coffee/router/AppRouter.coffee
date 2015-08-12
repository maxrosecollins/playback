class AppRouter extends Backbone.Router

	id : null

	# *other needs to be last
	routes:

		"login" : "loginRoute"
		"playlists/:id" : "singlePlaylistRoute"
		"playlists" : "playlistRoute"
		"profile" : "profileRoute"
		"recent-listens" : "profileListensRoute"
		"edit-profile" : "editProfileRoute"
		":username" : "publicUserRoute"
		"*other" : "defaultRoute"

	start: ->
		Backbone.history.start()

		$(document).on "click", "a:not([data-bypass])", (evt) ->
			href = $(this).attr("href")
			protocol = @protocol + "//"

			if href.slice(protocol.length) isnt protocol
				evt.preventDefault()
				app.router.navigate href, true

	# Default

	defaultRoute: ->
		# appview only handles 1 sub-view atm  # new LandingView()
		if app.view == null
			app.view = new AppView()

		app.view.ContentView.switchSubView app.view.ContentView.searchView

	publicUserRoute: (username) ->

		app.view.ContentView.switchSubView app.view.ContentView.userView
		app.view.ContentView.userView.switchSubView app.view.ContentView.userView.profileSummaryView
		app.view.ContentView.userView.render()
		app.view.ContentView.userView.is_public = true
		app.view.ContentView.userView.setProfileUser username #carries on inside here, since it contains an async process

	playlistRoute: ->

		if localStorage.getItem('user') == null
			@navigate 'login', true
		else
			app.view.ContentView.userView.is_public = false
			app.view.ContentView.userView.render()
			app.view.ContentView.switchSubView app.view.ContentView.userView
			app.view.ContentView.userView.switchSubView app.view.ContentView.userView.playlistsView
			#$('.main').scrollTop(0)

	singlePlaylistRoute: (id) ->

		if localStorage.getItem('user') == null
			@navigate 'login', true
		else
			app.view.ContentView.userView.is_public = false
			app.view.ContentView.userView.render()
			app.view.ContentView.switchSubView app.view.ContentView.userView
			app.view.ContentView.userView.switchSubView app.view.ContentView.userView.singlePlaylistView
			app.view.ContentView.userView.singlePlaylistView.render id

	profileRoute: ->
		
		if localStorage.getItem('user') == null
			@navigate 'login', true
		else
			app.user = JSON.parse(localStorage.getItem('user'))
			app.view.ContentView.userView.is_public = false
			app.view.ContentView.userView.render()
			app.view.ContentView.switchSubView app.view.ContentView.userView
			app.view.ContentView.userView.switchSubView app.view.ContentView.userView.profileSummaryView

	profileListensRoute: ->
		
		if localStorage.getItem('user') == null
			@navigate 'login', true
		else
			app.view.ContentView.userView.is_public = false
			app.view.ContentView.userView.render()
			app.view.ContentView.switchSubView app.view.ContentView.userView
			app.view.ContentView.userView.switchSubView app.view.ContentView.userView.recentListensView

	editProfileRoute: ->

		if localStorage.getItem('user') == null
			@navigate 'login', true
		else
			app.view.ContentView.userView.is_public = false
			app.view.ContentView.userView.render()
			app.view.ContentView.switchSubView app.view.ContentView.userView
			app.view.ContentView.userView.switchSubView app.view.ContentView.userView.editProfileView


	loginRoute: ->

		if !app.view.ContentView.subview
			app.view.ContentView.switchSubView app.view.ContentView.searchView
		app.view.ModalView.renderChild 'login'
