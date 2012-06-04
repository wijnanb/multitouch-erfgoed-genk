class Content extends Backbone.Model
	defaults:
		title: "Title"
		date: Date.now()
		description: "Lorem ipsum dolor sit amet..."
		fiche:
			title: "Titel"
			object: "Object"
			collection: "Collectie"
			material: "Materiaal"
			longitude: 50.0
			lattitude: 4.5
			zoom: 14	

	initialize: () ->
		console.log "Content.initialize", this.get('title'), this.niceDate()

	niceDate: () ->
		months = ["januari", "februari", "maart", "april", "mei", "juni", "juli", "augustus", "september", "oktober", "november", "december"]
		this.get('date').getDate() + " " + months[this.get('date').getMonth()] + " " + this.get('date').getFullYear()

window.Content = Content
