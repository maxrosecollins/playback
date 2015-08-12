class RecordHistory extends Backbone.Model

	urlRoot: '/history'

	song: {
		"duration": 0, # seconds
		"source": "", # yt, sc, ex
		"source_id": "", # e.g. yt 93ASUImTedo
		"title": "" # e.g. Disclosure - Latch
		"thumbnail": ""
	}