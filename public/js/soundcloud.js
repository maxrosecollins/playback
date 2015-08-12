//SoundCloud Data API
SC.initialize({
	client_id: '9c902604f68b8ce7ddf547273851bcc8'
});

//SoundCloud Streaming API
var scPlayer = function() {};

scPlayer.prototype.soundObject = null; /* dynamically updated by `load` */

scPlayer.prototype.load = function(id) {
	SC.stream("/tracks/"+id, function(sound){
		sound.play({
			onload: function(bool) {
				app.view.PlayerView.trackDuration.html(scPlayer.getDuration().toHHMMSS());
			}
		});
		scPlayer.soundObject = sound;
	});
};

scPlayer.prototype.play = function() {
	if (scPlayer.soundObject !== null) {
		scPlayer.soundObject.play();
	}
};

scPlayer.prototype.pause = function() {
	if (scPlayer.soundObject !== null) {
		scPlayer.soundObject.pause();
	}
};

scPlayer.prototype.getCurrentTime = function() {
	if (scPlayer.soundObject !== null) {
		return scPlayer.soundObject.position / 1000;
	}
};

scPlayer.prototype.getDuration = function() {
	if (scPlayer.soundObject !== null) {
		return scPlayer.soundObject.duration / 1000;
	}
};

scPlayer.prototype.getVolume = function() {
	if (scPlayer.soundObject !== null) {
		return scPlayer.soundObject.volume;
	}
};

scPlayer.prototype.setVolume = function(volume) {
	if (scPlayer.soundObject !== null) {
		return scPlayer.soundObject.setVolume(volume);
	}
};

scPlayer.prototype.seekTo = function(seconds) {
	if (scPlayer.soundObject !== null) {
		return scPlayer.soundObject.setPosition(seconds * 1000);
	}
};

scPlayer = new scPlayer();