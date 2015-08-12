class SearchResultsView extends SearchView

	el: $('.result-page')

	list: $('.result-page')

	template: _.template($('#search-results-template').html())

	currentPage: 0

	events:
		"click .search-result" : "queueSong"

	initialize: ->
		console.log "SearchResultsView initialized"

	render: (results) ->

		# Empty data set
		if results.length < 1

			$(this.el).html '<li style="width: 100%; text-align:center;"><h2 style="color:white">No results.</h2></li>'

		else

			# `results` is a standarized array regardless of source
			@renderResults(results)

	renderResults: (results) ->

		if Modernizr.touch == true
			i = 4
		else
			i = 8

		resultObjects = []

		if results and results[0] # Results found
			@list.empty()
			@results = results # used seperately by Queue etc

		else if results and !results[0] # No results
			@noResults()

		# render layout template
		$(this.el).html @template(
				results : results
				startAt : @currentPage
				perPage : i
			)


		#grab thumbnails that aren't found
		@populateEmptyThumbnails()

		$searchResults = $('.search-result')
		$pagination = $('#pagination')

		#animate results in
		$searchResults.each( (i) ->
			$(this).delay(i*150).fadeIn()
		)


		#animate pagination in
		$pagination.fadeIn()

	show: ->
		$(this.el).show()

	hide: ->
		$(this.el).hide()

	populateEmptyThumbnails: ->
		items_awaiting_thumbnails = $('#search #search-results li .thumbnail.not-found')
		self = @
		items_awaiting_thumbnails.each ->
			self.fetchNewThumbnail($(this).attr("data-title"), $(this))

	fetchNewThumbnail: (title, element) ->
		getLastFmThumbnail title, element

	recieveLastFmThumbnail: (data, element) ->
		if data.results.trackmatches? and data.results.trackmatches.track? and data.results.trackmatches.track[0]? and data.results.trackmatches.track[0].image?
			if data.results.trackmatches.track[0].image[3]?
				image = data.results.trackmatches.track[0].image[3]
			else if data.results.trackmatches.track[0].image[2]?
				image = data.results.trackmatches.track[0].image[2]
			else if data.results.trackmatches.track[0].image[1]?
				image = data.results.trackmatches.track[0].image[1]

		if image?
			exLrgImgThumb = image["#text"]
			$(element).attr "src", exLrgImgThumb
			$(element).removeClass "not-found"

	prepareForQuery: ->

		@list.empty()
		@$el.html '<div class="loading-dots">
                    <div class="loading-dot"></div>
                    <div class="loading-dot"></div>
                    <div class="loading-dot"></div>
                    <div class="loading-dot"></div>
                    <div class="loading-dot"></div>
                   </div>'

	noResults: ->

		@list.empty()
		@list.append 'No results found.'

	queueSong: (e) ->

		if Modernizr.touch == true
			$self = $(e.currentTarget)
			$self.addClass('added');
			setTimeout(->
					$self.children('.result-overlay').animate('opacity', '0');
					$self.removeClass('added');
			, 1000)
		else 
			$self = $(e.currentTarget)
			$self.addClass('added');
			$self.find('.message').text('Added to Queue');
			setTimeout(->
					$self.children('.result-overlay').animate('opacity', '0');
					$self.removeClass('added');
					$self.find('.message').text('Add to Queue');
			, 1000)

		if app.queue.songs.length == 0
			autoPlay = true

		li = $(e.currentTarget)
		source = li.attr 'data-source'
		id = li.attr 'data-id'
		title = li.attr 'data-title'
		owner = li.attr 'data-owner'
		thumbnail = li.attr 'data-thumbnail'
		duration = li.attr 'data-duration'

		_gaq.push(['_trackEvent', 'Queue', 'add', title]);

		song =
			"source" : source
			"id" : id
			"title" : title
			"owner" : owner
			"thumbnail" : thumbnail
			"duration" : duration

		app.queue.songs.push song

		app.view.QueueView.appendToQueue()

		if autoPlay == true
			app.view.PlayerView.play()


