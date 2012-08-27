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
		location:	
			longitude: 50.0
			lattitude: 4.5
			zoom: 14	

	initialize: () ->
		this.set "title": this.id + " " + this.get('title')

	niceDate: () ->
		date = new Date this.get('date')
		months = ["januari", "februari", "maart", "april", "mei", "juni", "juli", "augustus", "september", "oktober", "november", "december"]
		date.getDate() + " " + months[date.getMonth()] + " " + date.getFullYear()


class ContentCollection extends Backbone.Collection
	model: Content
	url: config.host + "api/content"

	initialize: () ->
		this.fetch()

window.Content = Content
window.ContentCollection = ContentCollection



###
app					server

fetch
					api/content
					<-  JSON
parse
create models
fire event "reset"
###