class UserView extends AppView

	name: 'userview'

	el: $('#user_view')

	template: $('#user-view-template').html()

	is_public: false

	subview: null

	playlistDataReturned: false

	historyDataReturned: false

	locally_stored_user: JSON.parse(localStorage.getItem 'user')

	initialize: ->
		console.log "UserView initialized"

		@profileSummaryView = new ProfileSummaryView()
		@recentListensView = new RecentListensView()
		@playlistsView = new PlaylistsView()
		@singlePlaylistView = new SinglePlaylistView()
		@editProfileView = new EditProfileView()

		if @subview == null
			@switchSubView @profileSummaryView

		#@render()

	render: ->

		if app.user != null
			if @is_public == true
				@$el.html _.template(@template, { user : app.user, is_public : true })
			else
				@$el.html _.template(@template, { user : app.user })

	resetUser: ->

		if @locally_stored_user != null
			app.user = locally_stored_user

	setProfileUser: (username) ->

		# Replacing with sending 'public' into template.
		if @locally_stored_user != null and @locally_stored_user.username == username
			# Not a public user: enables the 'edit' button.
			@is_public = false


		# Get user by username.
		public_user = new PublicUser( { 'username' : username } )
		public_user.url = '/users/' + username

		public_user.fetch(

			success: (model, response, options) =>
				console.log 'user switched to', username
				app.user = response[0]
				@render()
				#@switchSubView @ProfileSummaryView
				
				playlists = new Playlists()
				playlists.url = '/playlists/' + app.user.id
				playlists.fetch(
					success: (model, response, options) =>
						app.playlists = response
						@switchSubView @profileSummaryView
					error: (model, xhr, options) =>
						#console.log 'failed to grab play someone else\'s playlists.'
						#console.log model, xhr, options
				)



			error: (model, xhr, options) =>
				console.log "failed to find the user '"+username+"'."
				#console.log model, xhr, options

		)

	switchSubView: (subview) ->

		#update which nav element is 'current'
		$(@$el.find('nav a')).removeClass 'current'
		navEls = @$el.find('nav a')

		if subview.name == 'recent-listens'
			$(navEls[0]).addClass('current')
		else if subview.name == 'playlists' or subview.name == 'playlist'
			$(navEls[1]).addClass('current')

		# Hide previous subview
		if @subview
			@subview.hide()

		# Show new tab
		subview.show()

		# Update ContentView's subview
		@subview = subview


	show: ->

		@$el.show()