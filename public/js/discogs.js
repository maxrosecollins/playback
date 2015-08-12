var discogs = {

	apiBaseUrl: "http://api.discogs.com/",

	search: function (query, callback) {
		//http://api.discogs.com/database/search?q= <term> & type = <release*, master, artist, label>
		var searchUrl = this.apiBaseUrl + "database/search";

		$.ajax({
			url : searchUrl,
			type: "GET",
			dataType: "jsonp",
			data: {
				"q" : query,
				"type" : "release"
			},
			success: function(response) {
				callback(response);
			},
			error: function(response) {
				callback(response);
			}
		});
	},

	getReleaseData: function (release_id, callback) {
		//http://api.discogs.com/releases/ <release id>
		var releasesUrl = this.apiBaseUrl + "releases/" + release_id;

		$.ajax({
			url : releasesUrl,
			type: "GET",
			dataType: "jsonp",
			success: function(response) {
				callback(response);
			},
			error: function(response) {
				callback(response);
			}
		});
	}

};