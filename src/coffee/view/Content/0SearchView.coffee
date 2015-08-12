class SearchView extends AppView

	name: 'searchview'

	el: $('#search')

	searchTerm: $('#search #search-form #search-input')

	searchForm: $('#search-form')

	firstSearchDone: false

	searchYoutube: true
	searchSoundcloud: true
	searchEXFM: true

	resultOptions = $('#result-options')

	initialize: ->
		console.log "SearchView initialized"
		@searchResultsView = new SearchResultsView()

	events:
		"submit #search-form" : "submitSearch"
		"click #pagination a" : "changePage"
		"click #results-source a.yt" : "toggleYoutubeResults"
		"click #results-source input.yt" : "toggleYoutubeResults"
		"click #results-source a.sc" : "toggleSoundCloudResults"
		"click #results-source input.sc" : "toggleSoundCloudResults"
		"click #results-source a.exfm" : "toggleEXFMResults"
		"click #results-source input.exfm" : "toggleEXFMResults"

	toggleYoutubeResults: (e) =>
		if $(e.currentTarget).hasClass 'source'
			e.preventDefault()
		@searchYoutube = !@searchYoutube
		$('#results-source input.yt').prop('checked', @searchYoutube)
		@submitSearch()

	toggleSoundCloudResults: (e) =>
		if $(e.currentTarget).hasClass 'source'
			e.preventDefault()
		@searchSoundcloud = !@searchSoundcloud
		$('#results-source input.sc').prop('checked', @searchSoundcloud)
		@submitSearch()

	toggleEXFMResults: (e) =>
		if $(e.currentTarget).hasClass 'source'
			e.preventDefault()
		@searchEXFM = !@searchEXFM
		$('#results-source input.exfm').prop('checked', @searchEXFM)
		@submitSearch()

	submitSearch: (e) =>

		@searchTerm.blur()

		if Modernizr.touch == true 
			@firstSearchDone = true

		if e
			e.preventDefault()

		if @searchTerm.val() == ''
			return

		@resetPagination()

		if @firstSearchDone == false
			# make these 880 height
			$('.main.wrapper').height(880)
			$('#background').height('100%')
			# animate then search
			if Modernizr.touch == false 
				@searchForm.animate( { 'top' : '11%' }, 400, => @searchQuery(e) )
			@firstSearchDone = true
		else
			@searchQuery(e)

	resetPagination: ->

		pagination = $('#pagination ul')
		pagination.html '<li><a href="" id="current" data-pageno="0"></a></li>'


	paginate: (pageCount) ->

	    pagination = $('#pagination ul')

	    i = 0
	    while (i < pageCount)
	    	pagination.append '<li><a href="" data-pageno="'+(i+1)+'"></a></li>'
	    	i++

	changePage: (e) ->

		e.preventDefault()
		pageNo = $(e.currentTarget).attr 'data-pageno'
		$('#pagination a#current').attr 'id', ''
		$(e.currentTarget).attr 'id', 'current'

		@searchResultsView.currentPage = pageNo
		@searchResultsView.render(@searchResultsView.results)

		_gaq.push(['_trackEvent', 'Search', 'Page', pageNo]);

	searchQuery: (e) ->

		if Modernizr.touch == false 

			resultOptions.fadeIn()

		@searchResultsView.prepareForQuery()

		@youtubeResults = null
		@soundcloudResults = null
		@exFmResults = null
		@aggregatedResults = []

		searchTerm = @searchTerm.val()


		_gaq.push(['_trackEvent', 'Search', 'Query', searchTerm]);

		if Modernizr.touch == false
			if @searchYoutube == true
				@queryYouTube(searchTerm)

			if @searchSoundcloud == true
				@querySoundCloud('/tracks', searchTerm)

			if @searchEXFM == true
				@queryExFm(searchTerm)
		else
			if @searchEXFM == true
				@queryExFm(searchTerm)


	querySoundCloud: (endpoint, query) ->
		# Async SoundCloud request (callback -> @recieveSoundCloudResults)
		SC.get endpoint, { q: query }, (results) =>
			@recieveSoundCloudResults results

	queryYouTube: (query) ->
		# Async YouTube request (callback -> @recieveYouTubeResults)
		searchYoutube query

	queryExFm: (query) ->
		searchExFm query

	recieveSoundCloudResults: (results) ->
		formattedResults = @reformatResults('sc', results)
		@soundcloudResults = formattedResults
		@checkQueryCallbacks()

	recieveYouTubeResults: (results) ->
		formattedResults = @reformatResults('yt', results)
		@youtubeResults = formattedResults
		@checkQueryCallbacks()

	recieveExFmResults: (results) ->
		formattedResults = @reformatResults('exfm', results)
		@exFmResults = formattedResults
		@checkQueryCallbacks()

	reformatResults: (source, results) ->
		#return results;

		# Need to extract/pass: ID, Source [YT, SC, EX], Permalink, PurchaseURL(optional), Title, Artist (optional)
		#

		# Duration can be grabbed from the respective player later on
		resultSet = []

		if source == 'exfm' 
			#reformat exfm results
			i = 0
			while (i < results.length)
				if results[i].sources and results[i].sources[0]?
					permalink = results[i].sources[0]
				else
					permalink = null
				if results[i].url.indexOf('soundcloud') == -1
					currentResult =
						"source" : "ex"
						"id" : results[i].url
						"permalink" : permalink
						"purchaseUrl" : results[i].buy_link
						"title" : results[i].artist + " - " + results[i].title
						"artist" : results[i].artist
						"thumbnail" : null
						"owner" : null
						"duration" : results[i].duration / 1000
					resultSet.push currentResult
				else
					console.log "Filtered:",results[i].url
				i++

			return resultSet

		else if source == 'yt'
			#reformat youtube results
			i = 0
			if results
				while (i < results.length)
					videoID = results[i].media$group.yt$videoid.$t

					currentResult =
						"source" : "yt"
						"id" : videoID
						"permalink" : results[i].media$group.media$player.url
						"purchaseUrl" : null
						"title" : results[i].media$group.media$title.$t
						"thumbnail" : "http://i.ytimg.com/vi/"+videoID+"/hqdefault.jpg"
						"owner" : results[i].author[0].name.$t
						"duration" : results[i].media$group.yt$duration.seconds
					resultSet.push currentResult
					i++

			return resultSet

		else if source == 'sc'
			#reformat exfm results
			i = 0
			while (i < results.length)
				currentResult =
					"source" : "sc"
					"id" : results[i].id
					"permalink" : results[i].permalink_url
					"purchaseUrl" : results[i].purchase_url
					"title" : results[i].title
					"thumbnail" : results[i].artwork_url
					"owner" : results[i].user.username
					"duration" : results[i].duration / 1000
				resultSet.push currentResult
				i++

			return resultSet

	checkQueryCallbacks: -> # Called after each asynch search query comes back

		if Modernizr.touch == false
			if @searchYoutube == true
				if @youtubeResults == null
					return
			if @searchSoundcloud
				if @soundcloudResults == null
					return
			if @searchEXFM
				if  @exFmResults == null
					return

		if @searchYoutube == true and @youtubeResults
			i = 0
			while i < @youtubeResults.length
				@aggregatedResults.push @youtubeResults[i]
				i++

		# How should we sort all these results?
		if @searchSoundcloud == true and @soundcloudResults
			i = 0
			while i < @soundcloudResults.length
				@aggregatedResults.push @soundcloudResults[i]
				i++

		if @searchEXFM == true and @exFmResults
			i = 0
			while i < @exFmResults.length
				@aggregatedResults.push @exFmResults[i]
				i++

		# Calculate number of pages (max 5 & page1 already visible) and populate pagination handles
		if Modernizr.touch == true
			i = 4
		else
			i = 8

		if @aggregatedResults.length > i
			pageCount = @aggregatedResults.length / i
			if pageCount > 4
				pageCount = 4
			@paginate(pageCount)

		#console.log "All results collected and aggregated: ", @aggregatedResults
		@searchResultsView.render(@aggregatedResults)