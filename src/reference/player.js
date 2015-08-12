window.RP_PLAYING = 100;
window.RP_PAUSED = 200;
window.RP_STOPPED = 300;
window.RP_THROTTLE = 5;
window.UI_UPDATEFREQ = 100;
$(function () {
    window.con = {
        hasConsole: false,
        info: function () {
            if (this.hasConsole) console.info.apply(console, arguments)
        },
        log: function () {
            if (this.hasConsole) console.log.apply(console, arguments)
        },
        warn: function () {
            if (this.hasConsole) console.warn.apply(console, arguments)
        },
        error: function () {
            if (this.hasConsole) console.error.apply(console, arguments)
        },
        debug: function () {
            if (this.hasConsole) console.debug.apply(console, arguments)
        },
        group: function () {
            if (this.hasConsole) console.group.apply(console, arguments)
        },
        groupEnd: function () {
            if (this.hasConsole) console.groupEnd.apply(console,
            arguments)
        }
    };
    if (typeof console != "undefined" && typeof Function.prototype.apply) con.hasConsole = true;
    $.jQueryRandom = 0;
    $.extend($.expr[":"], {
        random: function (c, d, b, e) {
            if (d == 0) $.jQueryRandom = Math.floor(Math.random() * e.length);
            return d == $.jQueryRandom
        }
    });
    window.player = {
        isIE: false,
        isFirefox: false,
        state: window.RP_STOPPED,
        isBuffering: false,
        shuffle: false,
        playbackPercentage: 0,
        playbackQuality: "higher",
        seekerBarTarget: ".seekbar",
        seekerTarget: ".seekbar strong",
        seekerBufferTarget: ".seekbar em",
        optionsTarget: "div.options",
        volumeBarTarget: ".volumebar",
        volumeTarget: ".volumebar strong",
        volume: 75,
        $empty: $(".empty"),
        $playlistBanter: $("#playlist .banter"),
        $itemBuffering: $('<span class="buffering"> [ buffering... ]</span>'),
        $itemLoading: $('<span class="loading"> [ loading... ]</span>'),
        $subredditsSpan: $(".subreddits"),
        selectedSubreddit: "dnb",
        subredditAfterId: false,
        subredditMode: "hot",
        playlist: {
            Target: "div#playlist",
            ItemTarget: "div#playlist > div.item",
            ItemTargetActive: "div#playlist > div.item.playing,div#playlist > div.item.paused",
            ItemTag: '<div class="item"></div>',
            $currentItem: false,
            loadedTracks: {},
            resetSubreddit: function () {
                window.player.subredditAfterId = false
            },
            Ready: function (a) {
                _gaq.push(["_trackEvent", "Playlist", "Add", a == true ? "auto" : "manual"]);
                if ($(window.player.playlist.ItemTarget).length == 0 || $(window.player.playlist.ItemTargetActive).nextAll().length < window.RP_THROTTLE) this.Add()
            },
            Add: function () {
                $subreddits = $(".subreddits a");
                if ($subreddits.length == 0) {
                    alert("You gotta pick at least one subreddit!");
                    return
                }
                var a = [];
                $subreddits.each(function () {
                    a.push($(this).text())
                });
                if (window.player.subredditAfterId == false) url = "http://www.reddit.com/r/" + a.join("+") + "/.json?jsonp=?";
                else url = "http://www.reddit.com/r/" + a.join("+") + "/.json?after=" + window.player.subredditAfterId + "&jsonp=?";
                url = url.replace("/.", "/" + window.player.subredditMode + "/.");
                url = url.replace(/#[a-z0-9]+/g, "");
                window.player.uiPlaylistStartLoading();
                $.getJSON(url, function (c) {
                    c = c.data;
                    for (var b = 0; b < c.children.length; b++) {
                        child = c.children[b].data;
                        if (typeof window.player.playlist.loadedTracks[child.name] !== "undefined") continue;
                        window.player.playlist.loadedTracks[child.name] = child.name;
                        $destination = $('<a class="title"></a>');
                        $destination.text(child.title).attr("href", child.url);
                        handler = child.domain.replace(/\..+/g, "");
                        $playlistItem = $(window.player.playlist.ItemTag);
                        $playlistItem.attr("playHandler", handler).attr("id", "id_" + child.name);
                        if (handler == "self") if (child.selftext_html) {
                            child.actualRedditLink = child.url;
                            var selfLinks = child.selftext_html.match(/href="(http:\/\/(www\.)?(youtube|soundcloud)\.com([^"]+))"/g);
                            if (selfLinks && selfLinks.length > 0) {
                                var newLinks = [];
                                for (var slC = 0; slC < selfLinks.length; slC++) {
                                    selfLink = selfLinks[slC];
                                    selfLink = selfLink.replace(/^href="|"$/g, "");
                                    var newLink = $.extend({}, child);
                                    if (selfLinks.length > 1) newLink.title = "[" + (slC + 1) + (slC == 3 && selfLinks.length > 4 ? "..." : "") + "] " + newLink.title;
                                    newLink.name += "_" + slC;
                                    newLink.url = selfLink;
                                    newLink.domain = /youtube/.test(selfLink) ? "youtube.com" : "soundcloud.com";
                                    if (slC > 2) newLink.moreLinks = selfLinks.length - slC - 1;
                                    newLinks.push({
                                        data: newLink
                                    });
                                    if (slC > 2) break
                                }
                                c.children.splice.apply(c.children, [b + 1, 0].concat(newLinks))
                            }
                        }
                        if (typeof window.player.handlers[handler] == "undefined");
                        else {
                            $item = window.player.handlers[handler].createPlaylistObjectFromLink($destination);
                            if ($item === false) continue;
                            if (typeof $item != "undefined") $playlistItem.append($item);
                            $title = $('<p class="title"></p>');
                            $title.text(child.title);
                            $controls = $('<p class="controls"></p>');
                            $user = $('<a class="author"></a>');
                            $user.text("submitted by: " + child.author).attr("href", "http://www.reddit.com/user/" + child.author);
                            $redditLink = $("<a>view on Reddit</a>");
                            if (child.moreLinks) $redditLink.append(" (" + child.moreLinks + " more links)");
                            $redditLink.attr("href", "http://www.reddit.com" + child.permalink);
                            $subredditLink = $('<a class="link">to: </a>');
                            $subredditLink.append(child.subreddit).attr("href", "http://reddit.com/r/" + child.subreddit);
                            $destination.html("follow link &raquo;");
                            $controls.append($user).append("&nbsp;").append($subredditLink).append("&nbsp;").append($redditLink).append("&nbsp;").append($destination);
                            $extraControls = $('<p class="controls right"></p>');
                            $hider = $("<a>remove</a>");
                            $hider.click(function () {
                                if ($(this).parents(".playing,.paused").length > 0) window.player.next();
                                $(this).parents("div.item").remove()
                            });
                            $extraControls.append($hider);
                            $playlistItem.addClass(handler).append($title).append($controls).append($extraControls);
                            if (child.actualRedditLink) $playlistItem.attr("selfLink", child.actualRedditLink);
                            $("a", $playlistItem).click(function (d) {
                                d.stopPropagation()
                            }).attr("target", "_blank");
                            if (!window.player.handlers[handler].isReady) $playlistItem.addClass("disabled");
                            $(window.player.$empty).before($playlistItem)
                        }
                    }
                    if (c.children.length > 0) {
                        window.player.subredditAfterId = c.after || c.children[c.children.length - 1].data.name;
                    } else {
                        window.player.uiPlaylistStopLoading();
                        alert('No more links found!');
                        return;
                    }
                    window.player.uiPlaylistStopLoading();
                    window.player.uiToggleBanter(null, true);
                    if ($(window.player.playlist.ItemTarget).length == 0) {
                        alert("Are you sure you entered a valid subreddit? Looks like no playable items were found...");
                        return
                    }
                    window.player.$empty.addClass("notempty").removeClass("empty");
                    $("body").removeClass("noItems");
                    window.player.$playlistBanter.remove();
                    return true
                })
            },
            Empty: function () {
                _gaq.push(["_trackEvent", "Playlist", "Empty", ""]);
                window.player.stop();
                this.$currentItem = false;
                this.loadedTracks = {};
                this.resetSubreddit();
                $(this.ItemTarget).remove();
                window.player.$empty.addClass("empty").removeClass("notempty");
                $("body").addClass("noItems")
            },
            ExtendCurrentItem: function (a) {
                $extend = $('<div id="extension"></div>');
                for (i in a) $extend.append(a[i]);
                window.player.playlist.$currentItem.append($extend)
            }
        },
        buffering: function () {
            return Math.round(this.getLoadedPercentage()) < 100
        },
        play: function (a, b) {
            if (!this.playlist.$currentItem) {
                _gaq.push(["_trackEvent", "Player", "Play", "NO $CURRENTITEM"]);
                if ($(this.playlist.ItemTarget).length > 0) this.playlist.$currentItem = $(this.playlist.ItemTarget + ":eq(0)");
                else {
                    this.playlist.Add(true);
                    return
                }
            } else if (this.state == window.RP_PLAYING) this.stop(false, true);
            if (typeof a == "undefined") a = this.playlist.$currentItem;
            else this.playlist.$currentItem = a;
            $("#portablecontrols h3").text(this.playlist.$currentItem.find("p.title").text());
            if (typeof this.handlers[a.attr("playHandler")] == "undefined");
            else {
                if (this.state == window.RP_PAUSED) {
                    this.handlers[a.attr("playHandler")].resume(a);
                    _gaq.push(["_trackEvent", "Player", "Resume", a.attr("playHandler")])
                } else {
                    this.handlers[a.attr("playHandler")].play(a);
                    _gaq.push(["_trackEvent", "Player", "Play", (b == true ? "auto" : "manual") + " - " + a.attr("playHandler")])
                }
                window.player.state = window.RP_PLAYING;
                $(window.player.playlist.ItemTarget).removeClass("paused").removeClass("playing");
                a.addClass("playing");
                a.attr("played", "played");
                window.player.uiSetupVoterFrame(a)
            }
            this.playlist.Ready()
        },
        stop: function (a, b) {
            if (a == false || typeof a == "undefined") a = this.playlist.$currentItem;
            if (!a) return;
            if (typeof this.handlers[a.attr("playHandler")] == "undefined");
            else {
                _gaq.push(["_trackEvent", "Player", "Stop", b == true ? "auto" : "manual"]);
                this.uiRemoveExtentions();
                this.handlers[a.attr("playHandler")].stop(a);
                window.player.uiUpdateSeekbar(true);
                this.state = window.RP_STOPPED;
                a.removeClass("playing").removeClass("paused")
            }
        },
        pause: function (a) {
            if (typeof a == "undefined") a = this.playlist.$currentItem;
            if (typeof this.handlers[a.attr("playHandler")] == "undefined");
            else {
                _gaq.push(["_trackEvent", "Player", "Pause", a.attr("playHandler")]);
                this.handlers[a.attr("playHandler")].pause(a);
                this.state = window.RP_PAUSED;
                a.removeClass("playing").addClass("paused")
            }
        },
        prev: function () {
            if (!this.playlist.$currentItem);
            else {
                _gaq.push(["_trackEvent", "Player", "Prev", "manual"]);
                $prevItem = this.playlist.$currentItem.prev();
                this.stop(this.playlist.$currentItem);
                this.play($prevItem)
            }
        },
        next: function (a) {
            if (!this.playlist.$currentItem);
            else {
                _gaq.push(["_trackEvent", "Player", "Next", a == true ? "auto" : "manual"]);
                if (this.shuffle) $nextItem = $(this.playlist.ItemTarget + ":not([played]):random");
                else $nextItem = this.playlist.$currentItem.next();
                this.stop(this.playlist.$currentItem, a);
                this.play($nextItem, a)
            }
        },
        seekToPercentage: function (a) {
            if (!this.playlist.$currentItem);
            else {
                len = Math.round(this.getDuration() * (a / 100));
                this.handlers[this.playlist.$currentItem.attr("playHandler")].seekTo(len)
            }
        },
        setVolume: function (a) {
            for (handler in this.handlers) this.handlers[handler].setVolume(a);
            this.cookiesSetValue("volume", a)
        },
        setPlaybackQuality: function () {
            $this = $(this);
            window.player.playbackQuality = $this.val();
            for (handler in window.player.handlers) window.player.handlers[handler].setPlaybackQuality(window.player.playbackQuality)
        },
        getDuration: function () {
            len = -1;
            if (!this.playlist.$currentItem);
            else if (typeof this.handlers[this.playlist.$currentItem.attr("playHandler")] == "undefined");
            else len = this.handlers[this.playlist.$currentItem.attr("playHandler")].getDuration(this.playlist.$currentItem);
            return len
        },
        getCurrentTime: function () {
            len = -1;
            if (!this.playlist.$currentItem);
            else if (typeof this.handlers[this.playlist.$currentItem.attr("playHandler")] == "undefined");
            else len = this.handlers[this.playlist.$currentItem.attr("playHandler")].getCurrentTime(this.playlist.$currentItem);
            return len
        },
        getCurrentTimePercentage: function () {
            window.player.playbackPercentage = window.player.getCurrentTime() / window.player.getDuration() * 100;
            if (isNaN(window.player.playbackPercentage)) window.player.playbackPercentage = 0;
            return window.player.playbackPercentage
        },
        getLoadedPercentage: function () {
            len = 0;
            if (!this.playlist.$currentItem);
            else if (typeof this.handlers[this.playlist.$currentItem.attr("playHandler")] == "undefined");
            else len = this.handlers[this.playlist.$currentItem.attr("playHandler")].getLoadedPercentage();
            if (isNaN(len)) len = 0;
            return len
        },
        getBufferingStartPerc: function () {
            start = 0;
            if (this.playlist.$currentItem) if (typeof this.handlers[this.playlist.$currentItem.attr("playHandler")] == "undefined");
            else start = this.handlers[this.playlist.$currentItem.attr("playHandler")].getBufferingStartPerc();
            if (isNaN(start)) start = 0;
            return start
        },
        getPlaybackStartPerc: function () {
            start = 0;
            if (this.playlist.$currentItem) if (typeof this.handlers[this.playlist.$currentItem.attr("playHandler")] == "undefined");
            else start = this.handlers[this.playlist.$currentItem.attr("playHandler")].getPlaybackStartPerc();
            if (isNaN(start)) start = 0;
            return start
        },
        getSelectedSubreddit: function () {
            WONDERFUL = $("select[name=subreddit] option:selected").attr("value");
            if (WONDERFUL == "other") WONDERFUL = $("input[name=other_subreddit]").val();
            return WONDERFUL
        },
        empty: function () {
            this.playlist.Empty()
        },
        populate: function () {
            this.playlist.Add(true)
        },
        handlers: {},
        uiUpdate: function () {
            if (!window.player.playlist.$currentItem) return;
            $header = $("header");
            $body = $("body");
            $document = $(document);
            if (window.player.isIE && $.fx.off) $("#portablecontrols").css("top", $(this).scrollTop() + "px");
            if ($document.scrollTop() > $header.height()) $("#portablecontrols").fadeIn();
            else $("#portablecontrols").fadeOut()
        },
        uiToggleBanter: function (b, a) {
            return;
            if ($(".beenHidden").length == 0 && a) $(".banter > h2 ~ *").slideUp("slow");
            if (!a) $("> h2 ~ *", this).slideToggle("slow");
            if ($(".beenHidden").length == 0 && a) $(".banter").addClass("beenHidden").find("> h2").append(" <small><em>( click to show/hide again )</em></small>")
        },
        uiSetQuality: function () {
            extra = "";
            if ($(window.player.playlist.ItemTarget).length == 0) extra = " (no items loaded)";
            _gaq.push(["_trackEvent", "Player", "UI QUALITY", $(this).val() + extra]);
            switch ($(this).val()) {
                case "high":
                    $("body").addClass("superlowQualityUI").addClass("lowQualityUI").addClass("highQualityUI");
                    $.fx.off = false;
                    break;
                case "low":
                    $("body").addClass("superlowQualityUI").addClass("lowQualityUI").removeClass("highQualityUI");
                    $.fx.off = true;
                    break;
                case "superlow":
                default:
                    $("body").addClass("superlowQualityUI").removeClass("lowQualityUI").removeClass("highQualityUI");
                    break
            }
        },
        uiSetSubredditMode: function () {
            window.player.subredditMode = $(this).val()
        },
        uiSetShuffle: function () {
            window.player.shuffle = false;
            if ($(this).val() == "yes") window.player.shuffle = true
        },
        uiSetTheme: function () {
            $("html").removeClass("default").removeClass("skyline").addClass($(this).val())
        },
        uiSetBufferState: function () {
            if (this.buffering()) {
                $(this.playlist.Target).addClass("buffering");
                $(this.playlist.ItemTargetActive).find("p.title").append(this.$itemBuffering)
            } else {
                $(this.playlist.Target).removeClass("buffering");
                this.$itemBuffering.remove()
            }
        },
        uiSetErrorWithCurrentItem: function () {
            if (!this.playlist.$currentItem) return;
            this.playlist.$currentItem.addClass("error")
        },
        uiUpdateSeekbar: function (a) {
            this.uiUpdateSeekBufferBar(a);
            this.uiUpdateSeekPosBar(a);
            currentTime = this.getCurrentTime();
            min = Math.floor(currentTime / 60);
            sec = Math.floor(currentTime % 60);
            if (sec < 10) sec = "0" + sec;
            totalTime = this.getDuration();
            totalMin = Math.floor(totalTime / 60);
            totalSec = Math.floor(totalTime % 60);
            if (totalSec < 10) totalSec = "0" + totalSec;
            $(".elapsed").text(min + ":" + sec + " - " + totalMin + ":" + totalSec)
        },
        uiUpdateSeekBufferBar: function (a) {
            bufferingFrom = this.getBufferingStartPerc();
            loaded = this.getLoadedPercentage();
            remainingPercent = 100 - bufferingFrom;
            actualPercent = loaded * (remainingPercent / 100);
            $(this.seekerBufferTarget).css("left",
            bufferingFrom + "%");
            if (isNaN(actualPercent)) actualPercent = 0;
            if (a) $(this.seekerBufferTarget).stop().width(actualPercent + "%");
            else $(this.seekerBufferTarget).stop().width(actualPercent + "%")
        },
        uiUpdateSeekPosBar: function (a) {
            currentPosition = this.getCurrentTimePercentage();
            playingFrom = this.getPlaybackStartPerc();
            if (isNaN(currentPosition)) currentPosition = 0;
            if (isNaN(playingFrom)) playingFrom = 0;
            $(this.seekerTarget).css("left", playingFrom + "%");
            currentPosition = currentPosition - playingFrom;
            if (playingFrom < 0 || playingFrom > 100) playingFrom = 0;
            if (currentPosition < 0 || currentPosition > 100) currentPosition = 0;
            if (a) $(this.seekerTarget).stop().width(currentPosition + "%");
            else $(this.seekerTarget).stop().width(currentPosition + "%")
        },
        uiHoverSeekbar: function () {
            $(this).css("cursor", "pointer")
        },
        uiClickSeekbar: function (a) {
            seekerOffset = $(this).offset();
            pos = a.clientX - seekerOffset.left;
            perc = Math.round(pos / $(this).width() * 100);
            _gaq.push(["_trackEvent", "Player", "Seek", perc + "%"]);
            window.player.seekToPercentage(perc);
            window.player.uiUpdateSeekbar(true)
        },
        uiSetupVoterFrame: function (a) {
            $("#voterFrame").remove();
            $frame = $("<iframe></iframe>");
            var selfLink = a.attr("selfLink");
            $frame.attr("src", "http://www.reddit.com/static/button/button1.html?url=" + encodeURIComponent(selfLink ? selfLink : a.find("a.title").attr("href")));
            $div = $("<div></div>");
            $div.attr("id", "voterFrame");
            if (selfLink) $div.append("<small>[self post] </small> ").css({
                "text-align": "right",
                paddingRight: 10
            });
            else $div.append($frame);
            a.append($div)
        },
        uiHoverVolumebar: function (a) {
            $(this).css("cursor", "pointer")
        },
        uiClickVolumebar: function (a) {
            if (a === false) {
                VolumePerc = 75;
                cookieVol = window.player.cookiesGetValue("volume");
                if (cookieVol) VolumePerc = cookieVol
            } else {
                volOffset = $(window.player.volumeBarTarget).offset();
                pos = a.clientX - volOffset.left;
                VolumePerc = Math.round(pos / $(window.player.volumeBarTarget).width() * 100);
                _gaq.push(["_trackEvent", "Player", "Volume", VolumePerc + "%"])
            }
            if (VolumePerc > 100) VolumePerc = 100;
            window.player.volume = VolumePerc;
            window.player.setVolume(VolumePerc);
            $(window.player.volumeTarget).width(VolumePerc + "%")
        },
        uiPlaylistStartLoading: function () {
            $("body, #player").addClass("loading");
            $loadingOverlay = $("<div></div>");
            $playlist = $(window.player.playlist.Target);
            playlistOffset = $playlist.offset();
            $loadingOverlay.attr("id", "playlistLoading").html("<h1>Adding new items....</h1>").hide();
            $("body").append($loadingOverlay);
            $loadingOverlay.stop().fadeTo("normal", 0.9)
        },
        uiPlaylistStopLoading: function () {
            $("body, #player").removeClass("loading");
            $("#playlistLoading").stop().fadeOut("normal", function () {
                $("#playlistLoading").remove()
            })
        },
        uiHandlerIsEnabled: function (a) {
            $("." + a + ".disabled").removeClass("disabled")
        },
        uiSubredditSelector: function (a) {
            if ($(this).val() == "other") $("[name^=other_subreddit]").show();
            else {
                $("[name^=other_subreddit]").hide();
                window.player.selectedSubreddit = $(this).val();
                window.player.playlist.resetSubreddit()
            }
        },
        uiSetOtherSubreddit: function () {
            window.player.selectedSubreddit = $(this).val()
        },
        uiChooseSubreddit: function () {
            theSubreddit = window.player.getSelectedSubreddit();
            theSubreddit = window.player.selectedSubreddit;
            if (window.player.$subredditsSpan.find("a[subreddit=" + theSubreddit + "]").length > 0) return;
            window.player.uiAddSubreddit(theSubreddit)
        },
        uiAddSubreddit: function (b, a) {
            if (b) {
                $subreddit = $("<a></a>");
                $subreddit.text(b).addClass("button").attr("subreddit", b);
                window.player.$subredditsSpan.append($subreddit);
                $("body").removeClass("noSubreddits")
            }
            window.player.updateLinkToSubreddits();
            $currentSubreddits = window.player.$subredditsSpan.find("a");
            if ($currentSubreddits.length == 0) $("body").addClass("noSubreddits");
            if (a === true) return;
            currentSubreddits = [];
            for (i = 0; i < $currentSubreddits.length; i++) currentSubreddits[i] = $($currentSubreddits[i]).text();
            currentSubreddits = currentSubreddits.join("+");
            window.player.cookiesSetValue("chosen_subreddits", currentSubreddits)
        },
        uiRemoveExtentions: function () {
            $("#extension").remove()
        },
        uiShowNews: function () {
            if (!document.location.href.match(/http:\/\/(www.)?reddit/)) buildString = "Build 999:20131111";
            else buildString = $("footer p:last-child").text();
            dateParts = buildString.replace(/[^:]+:/, "").match(/(\d{4})(\d{2})(\d{2})/);
            now = Number(new Date) / 1E3;
            buildDate = Number(new Date(dateParts[1], dateParts[2] - 1, dateParts[3])) / 1E3;
            since = now - buildDate;
            if (since <= 60 * 60 * 24 * 7) $("#introToggle").html("(New updates!)")
        },
        cookiesSetValueFromField: function () {
            if (this.tagName == "OPTION") $this = $(this).parents("select");
            else $this = $(this);
            cookiename = $this.attr("name");
            cookievalue = $this.val();
            window.player.cookiesSetValue(cookiename, cookievalue)
        },
        cookiesSetValue: function (a, b) {
            cookiedays = 365;
            $.cookie("redditplaylister_" + a, b, {
                expires: cookiedays
            })
        },
        cookiesGetValue: function (a) {
            return $.cookie("redditplaylister_" + a)
        },
        stateWatcherInterval: null,
        setup: function () {
            this.stateWatcherInterval = window.setInterval(this.stateWatcher, window.UI_UPDATEFREQ);
            $(window).scroll(window.player.uiUpdate);
            $("p.seekbar").mousemove(this.uiHoverSeekbar).click(this.uiClickSeekbar);
            $("p.volumebar").mousemove(this.uiHoverVolumebar).click(this.uiClickVolumebar);
            $(".banter").click(this.uiToggleBanter);
            $introToggle = $('<a id="introToggle">(What\'s this?)</a>');
            $introToggle.data("introVisible",
            false).click(function () {
                if ($(this).data("introVisible")) {
                    $(".intro").stop().fadeOut();
                    $(this).data("introVisible", false)
                } else {
                    $(".intro").stop().fadeIn();
                    $(this).data("introVisible", true)
                }
            });
            $("h1").append("&nbsp;").append($introToggle);
            $optionsToggle = $("<a>(Options)</a>");
            $optionsToggle.data("introVisible", false).click(function () {
                if ($(this).data("introVisible")) {
                    $(".options").stop().fadeOut();
                    $(this).data("introVisible", false)
                } else {
                    $(".options").stop().fadeIn();
                    $(this).data("introVisible", true)
                }
            });
            $(".intro a.closer").click(function () {
                $('#introToggle').click();
            });
            $("h1").append("&nbsp;").append($optionsToggle);
            $("#playlist").delegate("div.item", "click", function () {
                if (!$(this).hasClass("disabled")) window.player.play($(this))
            });
            $(".subreddits").delegate("a", "click", function () {
                $(this).remove();
                window.player.uiAddSubreddit()
            }).delegate("a", "mouseover", function () {
                $(this).prepend("<span> - </span>")
            }).delegate("a", "mouseout", function () {
                $("span", this).remove()
            });
            this.uiClickVolumebar(false);
            this.setupOptions();
            this.setupFeatures();
            this.uiShowNews();
            var regex = /r=([^&]+)/;
            if (regex.test(document.location.href)) $("a.button.addItems").click()
        },
        setupOptions: function () {
            $(this.optionsTarget + " label").click(function (a) {
                a.stopPropagation()
            });
            $("[default]").each(function () {
                if (!window.player.cookiesGetValue($(this).attr("name"))) $(this).each(window.player.cookiesSetValueFromField)
            });
            $("input[name=uiQual]").val([$.cookie("redditplaylister_uiQual")]);
            $("input[name=uiShuffle]").val([$.cookie("redditplaylister_uiShuffle")]);
            $("input[name=uiTheme]").val([$.cookie("redditplaylister_uiTheme")]);
            $("input[name=playbackQuality]").val([$.cookie("redditplaylister_playbackQuality")]);
            $("input[name=other_subreddit]").val($.cookie("redditplaylister_other_subreddit"));
            $("select[name=subreddit]").val($.cookie("redditplaylister_subreddit"));
            $("input[name=subredditmode]").val([$.cookie("redditplaylister_subredditmode")]);
            $("[name=subreddit]").change(this.uiSubredditSelector).change();
            $("[name=other_subreddit]").keyup(window.player.playlist.resetSubreddit).keyup(window.player.uiSetOtherSubreddit);
            $("input[name=uiQual]").click(this.uiSetQuality);
            $("input[name=uiShuffle]").click(this.uiSetShuffle);
            $("input[name=subredditmode]").click(this.uiSetSubredditMode);
            $("input[name=uiTheme]").click(this.uiSetTheme);
            $("input[name=playbackQuality]").click(this.setPlaybackQuality);
            $("input, select").change(this.cookiesSetValueFromField);
            $("#chooseSubreddit").click(this.uiChooseSubreddit);
            var regex = /r=([^&]+)/;
            if (regex.test(document.location.href)) {
                var autoreddit = document.location.href.match(regex)[1];
                window.player.uiAddSubreddit(autoreddit, true)
            } else if (this.cookiesGetValue("chosen_subreddits")) {
                chosen_subreddits = this.cookiesGetValue("chosen_subreddits").split("+");
                for (i = 0; i < chosen_subreddits.length; i++) window.player.uiAddSubreddit(chosen_subreddits[i], true)
            }
            $("input:checked").click();
            if (window.player.selectedSubreddit == "other") $("input:text").keyup()
        },
        setupFeatures: function () {
            this.isIE = $.browser.msie && Number($.browser.version) <= 8;
            this.isFirefox = $.browser.mozilla;
            if (this.isIE || !$.support.opacity) {
                $("#portablecontrols").css("position", "absolute");
                $("input[name=uiQual][value=low]").click();
                $("input[name=uiQual][value=high]").parent("label").remove()
            }
            if (this.isFirefox) $("input[name=uiQual][value=low]").click()
        },
        stateWatcher: function () {
            if (window.player.playlist.$currentItem && (window.player.state == window.RP_PLAYING || window.player.state == window.RP_PAUSED)) {
                window.player.uiUpdateSeekbar();
                window.player.uiSetBufferState()
            }
        }
    };
    $("a[href^=#]").click(function () {
        var a = $(this).attr("href").replace(/[^a-z]/ig, "");
        window.player[a]()
    });
    window.player.updateLinkToSubreddits = function () {
        $("#shareUrl").hide();
        $("#shareUrl a").remove();
        var subreddits = [];
        $subreddit.parents(".subreddits").find("a").each(function () {
            subreddits.push($(this).text())
        });
        var share = "http://redditplayer.phoenixforgotten.com/?r=" + subreddits.join("+");
        if (subreddits.length > 0) {
            $("#shareUrl").prepend('<a class="" href="' + share + '" id="shareableUrl">' + share + "</a>");
            $("#shareUrl").show()
        }
    };
    $("#clippy_copied").hide();
    window.player.setup();
    return
});
clippyCopiedCallback = function (id) {
    $("#clippy_copied").stop().show().fadeOut(3E3)
};