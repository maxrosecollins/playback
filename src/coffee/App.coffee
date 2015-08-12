$ ->

	# Override Backbone.sync to support CORS requests by default.
	(->
		proxiedSync = Backbone.sync
		Backbone.sync = (method, model, options) ->
			options or (options = {})
			options.crossDomain = true  unless options.crossDomain
			options.xhrFields = withCredentials: true  unless options.xhrFields
			return proxiedSync(method, model, options)
	)()

	# Store app globally.
	window.app =
		router : null
		view : null
		user : JSON.parse(localStorage.getItem('user'))
		queue : 
			position : 0
			songs : []


	app.view = new AppView()


	String::toHHMMSS = ->
		sec_numb    = parseInt(this)
		hours   = Math.floor(sec_numb / 3600)
		minutes = Math.floor((sec_numb - (hours * 3600)) / 60)
		seconds = sec_numb - (hours * 3600) - (minutes * 60)
		if (hours   < 10)
			hours  = "0"+hours
		if (minutes < 10)
			minutes = "0"+minutes
		if (seconds < 10)
			seconds = "0"+seconds
		if hours == '00'
			time = minutes+':'+seconds
		else
			time = hours+':'+minutes+':'+seconds
		return time

	Number::toHHMMSS = ->
		sec_numb    = parseInt(this)
		hours   = Math.floor(sec_numb / 3600)
		minutes = Math.floor((sec_numb - (hours * 3600)) / 60)
		seconds = sec_numb - (hours * 3600) - (minutes * 60)
		if (hours   < 10)
			hours  = "0"+hours
		if (minutes < 10)
			minutes = "0"+minutes
		if (seconds < 10)
			seconds = "0"+seconds
		if hours == '00'
			time = minutes+':'+seconds
		else
			time = hours+':'+minutes+':'+seconds
		return time

	$(document).ready ->

		# init router
		app.router = new AppRouter()
		app.router.start()