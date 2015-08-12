function onYouTubePlayerReady(a) {
    window.player.handlers.youtube.yt_object = $("#dynytplayer").get(0);
    window.player.handlers.youtube.yt_object.addEventListener("onStateChange", "window.player.handlers.youtube.onStateChange");
    window.player.handlers.youtube.yt_object.addEventListener("onError", "window.player.handlers.youtube.onError");
    window.player.uiHandlerIsEnabled("youtube");
    window.player.handlers.youtube.isReady = true;
    window.player.handlers.youtube.setVolume(window.player.volume);
    window.player.handlers.youtube.setPlaybackQuality(window.player.playbackQuality)
}
$(function () {
    window.player.handlers.youtube = {
        isSetup: false,
        isReady: false,
        ytObject: null,
        qualityMap: {
            low: "small",
            medium: "medium",
            high: "high",
            higher: "hd720",
            moarhigher: "hd1080",
            highest: "highres"
        }

        ,
        onStateChange: function (a) {
            switch (a) {
                case 0:
                    window.player.next(true);
                    break;
                case 3:
                    break;
                case 1:
                case 5:
                    break
            }
            window.player.stateWatcher()
        }

        ,
        onError: function (a) {
            window.player.uiSetErrorWithCurrentItem();
            window.player.next(true)
        }

        ,
        play: function (a) {
            if (typeof window.player.handlers.youtube.yt_object.playVideo == "undefined") {

            } else {
                window.player.handlers.youtube.yt_object.loadVideoById($("a[yt_link]",
                a).data("youtubeId"),
                0,
                this.getValidPlaybackQuality(window.player.playbackQuality))
            }

        }

        ,
        resume: function (a) {
            if (typeof window.player.handlers.youtube.yt_object.playVideo == "undefined") {

            } else {
                window.player.handlers.youtube.yt_object.playVideo()
            }

        }

        ,
        stop: function (a) {
            if (typeof window.player.handlers.youtube.yt_object.stopVideo == "undefined") {

            } else {
                //window.player.handlers.youtube.yt_object.seekTo(0);
                //window.player.handlers.youtube.yt_object.stopVideo();
                window.player.handlers.youtube.yt_object.pauseVideo();
            }

        }

        ,
        pause: function (a) {
            if (typeof window.player.handlers.youtube.yt_object.pauseVideo == "undefined") {

            } else {
                window.player.handlers.youtube.yt_object.pauseVideo()
            }

        }

        ,
        seekTo: function (a) {
            if (typeof window.player.handlers.youtube.yt_object.pauseVideo == "undefined") {

            } else {
                window.player.handlers.youtube.yt_object.seekTo(a)
            }

        }

        ,
        createPlaylistObjectFromLink: function (a) {
            id = a.attr("href").match(/(\?|&)v=([^&]+)/g, "");
            if (id == null || typeof id[0] == "undefined") {
                return false
            }
            movieId = id[0].replace(/[&?]v=/gi, "");
            a.attr("yt_link",
            1).data("youtubeId",
            movieId);
            movieUrl = "http://www.youtube.com/v/" + movieId + "?version=3&rel=0&enablejsapi=1&color1=0xb1b1b1&color2=0xcfcfcf&hd=1&showsearch=0&iv_load_policy=3&feature=player_embedded";
            if (!window.player.handlers.youtube.isSetup) {
                window.player.handlers.youtube.setup(movieUrl)
            }

        }

        ,
        setVolume: function (a) {
            if (window.player.handlers.youtube.isReady) {
                window.player.handlers.youtube.yt_object.setVolume(a)
            }

        }

        ,
        getValidPlaybackQuality: function (a) {
            if (typeof window.player.handlers.youtube.qualityMap[a] !== "undefined") {
                a = window.player.handlers.youtube.qualityMap[a]
            } else {
                a = "default"
            }
            return a
        }

        ,
        setPlaybackQuality: function (a) {
            if (!this.isReady) {
                return
            }
            a = this.getValidPlaybackQuality(a);
            window.player.handlers.youtube.yt_object.setPlaybackQuality(a)
        }

        ,
        getDuration: function (a) {
            return window.player.handlers.youtube.yt_object.getDuration()
        }

        ,
        getCurrentTime: function (a) {
            return window.player.handlers.youtube.yt_object.getCurrentTime()
        }

        ,
        getLoadedPercentage: function () {
            perc = Math.round((Number(window.player.handlers.youtube.yt_object.getVideoBytesLoaded()) / Number(window.player.handlers.youtube.yt_object.getVideoBytesTotal())) * 100);
            if (isNaN(perc) || perc < 0) {
                perc = 0
            }
            return perc
        }

        ,
        getBufferingStartPerc: function () {
            vbt = window.player.handlers.youtube.yt_object.getVideoBytesTotal();
            vsb = window.player.handlers.youtube.yt_object.getVideoStartBytes();
            vbl = window.player.handlers.youtube.yt_object.getVideoBytesLoaded();
            total = vsb + vbt;
            return (vsb / total) * 100
        }

        ,
        getPlaybackStartPerc: function () {
            return this.getBufferingStartPerc()
        }

        ,
        setup: function (a) {
            $ytplayer = $('<div id="youtube_player">YTPLAYER</div>');
            $("body").append($ytplayer);
            params = {
                allowScriptAccess: "always",
                movie: a
            }

            ;
            atts = {
                id: "dynytplayer"
            }

            ;
            swfobject.embedSWF(a, "youtube_player", "700", "700", "9",
            null,
            null,
            params,
            atts);
            window.player.handlers.youtube.isSetup = true
        }

    }

});