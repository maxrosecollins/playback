class ModalView extends AppView
	
	el: $('#modal-wrapper')

	loginView: null
	signupView: null
	currentView: null

	initialize: ->
		console.log "AppView -> ModalView initialized"

		@loginView = new LoginView()
		@signupView = new SignupView()

	renderChild: (string) ->

		@show()

		if @currentView != null
			@currentView.hide()

		switch string
			when 'login'
				@loginView.show()
				@currentView = @loginView
			when 'signup'
				@signupView.show()
				@currentView = @signupView

	events:
		'click .overlay.clickzone' : 'hide'

	show: ->
		$(this.el).show()

	hide: ->
		$(this.el).hide()