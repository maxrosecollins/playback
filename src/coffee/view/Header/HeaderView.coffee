class HeaderView extends AppView
	
	el: $('.header-container')

	template: $('#user-dropdown-template').html()

	initialize: ->
		console.log 'HeaderView initialized'

		if app.user != null
			@populateWithUser(app.user)
		else if Modernizr.touch == false
			@$el.find('#login').show()

		
	
	events:
		'click li a.login' : 'showLogin'
		'click li a.signup' : 'showSignup'
		'mouseover .user-dropdown' : 'showDropdown'
		'mouseout .user-dropdown' : 'hideDropdown'
		'click .user-dropdown .logout' : 'logOut'

	show: ->
		$(this.el).show()

	hide: ->
		$(this.el).hide()

	showLogin: (e) ->

		e.preventDefault()
		app.view.ModalView.renderChild 'login'

	showSignup: (e) ->

		e.preventDefault()
		app.view.ModalView.renderChild 'signup'

	showDropdown: (e) ->
		@$el.find('.menu').removeClass 'hidden'

	hideDropdown: (e) ->
		@$el.find('.menu').addClass 'hidden'

	populateWithUser: (user) ->

		@$el.find('#login').hide()

		dropdown_html = _.template(@template, user)
		@$el.find('.user-dropdown').html(dropdown_html)
		@$el.find('.user-dropdown').show()

		@delegateEvents()

	logOut: (e) ->

		e.preventDefault()
		logout = new Logout()

		logout.fetch(

			success: (model, response, options) =>

				console.log 'successfully logged out.'
				localStorage.clear()
				app.view.ModalView.loginView.user.clear()
				@reset()

			error: (model, xhr, options) =>
				console.log 'failed to log out.'
				console.log model, xhr, options
		)

	reset: ->

		@$el.find('.user-dropdown').hide()
		@$el.find('#login').show()
		app.view.ContentView.switchSubView(app.view.ContentView.searchView)


