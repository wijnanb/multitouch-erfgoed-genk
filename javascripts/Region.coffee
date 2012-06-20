class Region extends Backbone.Model
	@TOP_LEFT: "top-left"
	@TOP: "top"
	@TOP_RIGHT: "top-right"
	@BOTTOM_LEFT: "bottom-left"
	@BOTTOM: "bottom"
	@BOTTOM_RIGHT: "bottom-right"

	@POSITIONS: [@TOP_LEFT, @TOP, @TOP_RIGHT, @BOTTOM_LEFT, @BOTTOM, @BOTTOM_RIGHT]

	defaults:
		position: null
		active: false

	initialize: () ->
		this.on "change:hover_position", this.onHover, this
		this.on "change:under", this.onUnder, this

	toggleActive: () ->
		this.set "active" : !this.get("active")




class RegionCollection extends Backbone.Collection
	model: Region
	
	initialize: () ->
		_.bindAll this
		this.reset()

	reset: () ->
		console.log Region.POSITIONS
		for position in Region.POSITIONS
			console.log position
			region = new Region position: position
			button = new RegionButton model: region
			button.render().$el.appendTo $("#regions")



class RegionView extends Backbone.View
	className: "region"
	
	initialize: () ->
		_.bindAll this 
		this.collection = this.options.collection

	render: () ->

		this






class RegionButton extends Backbone.View
	model: Region
	className: "region-button"

	events:
		"tap" : "ontap"

	initialize: () ->
		_.bindAll this
		this.collection = this.options.collection
		this.model.on "change:active", this.onActiveChanged

	render: () ->
		this.$el.addClass this.model.get "position"

		this.$el.html """
			<div class="piece horizontal"></div>
			<div class="piece vertical"></div>
		"""
		
		this

	ontap: (event) ->
		this.model.toggleActive()


	onActiveChanged: () ->
		this.$el.toggleClass "active", this.model.get("active")





window.Region = Region
window.RegionCollection = RegionCollection
window.RegionView = RegionView
window.RegionButton = RegionButton





