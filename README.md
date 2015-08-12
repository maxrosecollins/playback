# Playback.io

[Visit site](http://playback.io/)

A music web app that aggregates music from multiple sources into a bespoke interface.

Works on PS4! :godmode:

## About

This project was originally a university project, It is a Backbone application supported by an API, which is a Rails data-only app. It fetches music from YouTube, Soundcloud and ExFM.

## Status

The app was abandonded after being graded for the project. Recently, decided to use it, and was suprised at how well it stood the test of time (its about 2 years old)..

### Feature Ideas Archive

#### General
* Login
	+ Lazy login consisting of just email address
	+ Generate password for better security (alpha numeric, with symbols)
	+ Username is auto populated, can be changed.
	+ Social Login
* last.fm & discogs for artist data & meta data i.e. user data, possible amazon for artwork
* pretty interface
* notifications api
* scrobbling to last.fm
* play history
* flag/report
+ blacklist of mediasource id
+ Moderation tool
+ Comment hidding
* content aggregators: youtube, soundcloud, mixcloud, etc (4shared, hulkshare,soundowl)
* time stamped comments ala soundcloud
* web based / progressively enhanced / media query’d
* REST API

#### Playlists

#### Collab Radio’ mode
* Using nodejs for socket communication in order to play songs in sync accross clients
* Voting (details / purpose TBC)

## Other Details

#### Scaling
* NodeJS good for scaling
* If many users using radio feature, node will need strong processing: we could increase processing power by distrubuting mutliple servers
* backend could remain on 1 server that these processing servers interact with
* Caching for DB I/O
