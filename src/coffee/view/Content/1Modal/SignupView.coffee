class SignupView extends AppView
	
	el: $('.signup.modal')

	emailField: $('#signup-container #email')

	passwordField: $('#signup-container #password')

	user: null

	initialize: ->
		console.log "AppView -> SignupView initialized"
		@user = new Signup()

	events:
		'click .close-form' : 'closeModal'
		'submit form' : 'attemptSignup'

	show: ->
		$(this.el).show()

	hide: ->
		$(this.el).hide()

	closeModal: ->

		app.view.ModalView.hide()

	attemptSignup: (e) ->

		e.preventDefault()

		@resetError()

		@user.set(
			'email' : @emailField.val()
			'password' : @passwordField.val()
			'password_confirmation' : @passwordField.val()
		)

		@user.save( @user.attributes, {

			success: (model, response, options) =>
				console.log 'successfully logged in!'
				console.log model, response, options

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