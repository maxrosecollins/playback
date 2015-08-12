class LandingView extends ContentView
	
	el: $('#landing')

	initialize: ->
		console.log "LandingView initialized"
		@render()

	render: ->

		return this

	show: ->
		$(this.el).show()

	hide: ->
		$(this.el).hide()