//namespace these functions!

var yt_player;
function onYouTubeIframeAPIReady() {
		yt_player = new YT.Player('yt_player', {
			height: '390',
			width: '640',
			videoId: 'hSjoavSafeM',
			events: {
				'onReady': onPlayerReady,
				'onStateChange': app.view.PlayerView.youtubeStateChange,
				'onError': app.view.PlayerView.youtubeError
			}
		});
}

function onPlayerReady(evt) {
	console.log(">>youtube player ready");
	app.view.PlayerView.youtubeReady();
}

function searchYoutube(query) {
	var keyword= encodeURIComponent(query),
		yt_url='http://gdata.youtube.com/feeds/api/videos?q='+keyword+'&v=2&alt=json&category=Music';
	
	$.ajax ({
		type: "GET",
		url: yt_url,
		dataType:"jsonp",
		success: function(response) {
			//Note: Requires SearchView to be active inside ContentView
			app.view.ContentView.subview.recieveYouTubeResults(response.feed.entry);
		},
		error: function(response) {
			//Note: Requires SearchView to be active inside ContentView
			app.view.ContentView.subview.recieveYouTubeResults(response);
		}
	});
}