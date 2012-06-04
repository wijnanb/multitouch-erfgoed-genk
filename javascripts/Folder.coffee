class Folder extends Backbone.Model
	initialize: () ->
		console.log "Folder.initialize"

class FolderView extends Backbone.View
	className: "folder"
	
	initialize: () ->
		console.log "FolderView.initialize"

	events:
		"click" : "click"


	click: () ->
		console.log "FolderView.click"

	render: () ->
		title = this.model.get('content').get('title')
		date = this.model.get('content').niceDate()

		this.$el.html """
			<h2>#{title}</h2>
			<div class="date">#{date}</div>
		"""

		this

window.Folder = Folder
window.FolderView = FolderView