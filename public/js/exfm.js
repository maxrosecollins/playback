ex_player = document.getElementById('ex_player');

exfmPlay = function(mp3) {
	$('#ex_player').attr('src', mp3);
	ex_player.play();

	ex_player.addEventListener('ended', goNext);

	ex_player.addEventListener('loadedmetadata', updateDuration);

	function updateDuration(e) {
		var prettyTime = ex_player.duration.toHHMMSS();
		app.view.PlayerView.trackDuration.html(prettyTime);
	}

	function goNext() {
		app.view.PlayerView.skip("forwards");
	}
};

exFmSeek = function(seconds) {
	ex_player.currentTime = seconds;
};

exFmSetVolume = function(volume) {
	ex_player.volume = (volume/100);
};

exFmGetVolume = function() {
	return (ex_player.volume*100);
};

exFmGetDuration = function() {
	return ex_player.getDuration;
};

exFmGetCurrentTime = function() {
	return ex_player.currentTime;
};

exFmPlay = function() {
	ex_player.play();
};

function searchExFm(query) {

	var keyword= encodeURIComponent(query),
		ex_url='http://ex.fm/api/v3/song/search/'+keyword;

	$.ajax ({
		type: "GET",
		url: ex_url,
		dataType:"jsonp",
		success: function(response) {
			//Note: Requires SearchView to be active inside ContentView
			app.view.ContentView.subview.recieveExFmResults(response.songs);
		},
		error: function(response) {
			//Note: Requires SearchView to be active inside ContentView
			app.view.ContentView.subview.recieveExFmResults(response);
		}
	});
}