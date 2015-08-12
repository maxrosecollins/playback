/*var lastfm = new LastFM({
	apiKey    : '4fc990a79226a7dea9ae1b7bb851ce9d',
	apiSecret : 'de2da71fba3b74a9f33f1823bdaab1d6'
});*/



function getLastFmThumbnail(trackname, element) {

	var keyword= encodeURIComponent(trackname),
		lastfm_url='http://ws.audioscrobbler.com/2.0/';

	$.ajax ({
		type: "GET",
		url: lastfm_url,
		data: {
			"method" : "track.search",
			"track" : keyword,
			"api_key" : "4fc990a79226a7dea9ae1b7bb851ce9d",
			"format" : "json"
		},
		dataType:"jsonp",
		success: function(response) {
			//Note: Requires SearchResultsView
			app.view.ContentView.subview.searchResultsView.recieveLastFmThumbnail(response, element);
		},
		error: function(response) {
			//Note: Requires SearchResultsView
			app.view.ContentView.subview.searchResultsView.recieveLastFmThumbnail(response, element);
		}
	});
}

