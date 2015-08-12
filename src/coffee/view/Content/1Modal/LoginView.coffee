class LoginView extends AppView
	
	el: $('.login.modal')

	emailField: $('#login-container #email')

	passwordField: $('#login-container #password')

	user: null

	initialize: ->
		console.log "AppView -> LoginView initialized"
		@user = new Login()

	events:
		'click .close-form' : 'closeModal'
		'submit form' : 'attemptLogin'

	show: ->
		$(this.el).show()

	hide: ->
		$(this.el).hide()

	closeModal: ->

		app.view.ModalView.hide()

	attemptLogin: (e) ->

		e.preventDefault()

		@resetError()

		@user.set(
			'email' : @emailField.val()
			'password' : @passwordField.val()
		)

		@user.save( @user.attributes, {

			success: (model, response, options) =>
				#console.log 'successfully logged in!'
				#console.log model, response, options

				@closeModal()
				app.view.HeaderView.populateWithUser(response.user)

				#Store user in cookie / localstorage
				localStorage.setItem 'user', JSON.stringify(response.user)
				app.user = response.user

				# Update User View views
				app.view.ContentView.userView.render()

				@loadPlaylists()

			error: (model, xhr, options) =>
				#console.log 'failed to log in.'
				#console.log model, xhr, options
				@showError()

		})

	show: ->

		@resetError()
		@$el.show()

	showError: ->

		@$el.find('.error').show()

	resetError: ->

		@$el.find('.error').hide()