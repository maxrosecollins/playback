class ContentView extends AppView
	
	el: $('.main')

	initialize: ->
		console.log "ContentView initialized"
		
		@searchView = new SearchView()
		@userView = new UserView()

		@render()

	render: (subview) ->

		if subview
			@switchSubView subview

			background = $('#background')

			background.load( () ->
				background.animate {'opacity' : '1'}, 300
			)

	show: ->
		@$el.show()

	hide: ->
		@$el.hide()

	switchSubView: (subview) ->

		if @subview == subview
			return false

		$('#sections li').removeClass 'active'
		if subview.name == 'searchview'
			$($('#sections li')[0]).addClass 'active'
		else
			$($('#sections li')[1]).addClass 'active'

		# Hide previous subview
		if @subview
			#@subview.hide()
			if @subview.name == 'searchview'
				# push left
				$(@subview.el).animate(
					'margin-left' : '-100%'
				, 500, ->
					$(this).hide()
					$(this).css 'margin-left', 0
				)
				
			else
				$(@subview.el).animate(
					'margin-left' : '100%'
				, 500, ->
					$(this).hide()
					$(this).css 'margin-left', 0
				)
				

		# Show new tab
		#subview.show()
		if @subview
			if subview.name == 'searchview'
				# push left
				$(subview.el).css 'margin-left', '-100%'
				subview.show()
				$(subview.el).animate(
					'margin-left' : '0'
				, 500)
				
			else
				$(subview.el).css 'margin-left', '100%'
				subview.show()
				$(subview.el).animate(
					'margin-left' : '0'
				, 500)
		else
			subview.show()

		# Update ContentView's subview
		@subview = subview