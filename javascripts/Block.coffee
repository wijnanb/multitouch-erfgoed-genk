class Block extends Backbone.Model
	defaults:
		position:
			x: 0
			y: 0
		drag_offset:
			x: 0
			y: 0
		active: false
		isDragging: false
	initialize: () ->
	
	positionOnGrid: () ->
		pixel_position = 
			x: this.get("position").x * config.block.width + this.get("drag_offset").x
			y: this.get("position").y * config.block.height + this.get("drag_offset").y

		pixel_position.x = Math.max 0, Math.min( pixel_position.x, config.screen_width )
		pixel_position.y = Math.max 0, Math.min( pixel_position.y, config.screen_height )

		this.set "position" :
			x: Math.round pixel_position.x / config.block.width
			y: Math.round pixel_position.y / config.block.height

		this.set "drag_offset": { x:0, y:0 }, silent: true

class BlockCollection extends Backbone.Collection
	model: Block
	
	initialize: () ->
		this.contentCollection = new ContentCollection()
		this.contentCollection.bind "reset", this.reset, this

	reset: () ->
		this.contentCollection.each (element,index,list) ->

			this.num_block_x = Math.floor config.screen_width / config.block.width
			this.num_block_y = Math.floor config.screen_height / config.block.height

			attributes = 
				content: element
				position:
					x: index % this.num_block_x
					y: Math.floor index / this.num_block_x

			block = new BlockView( model: new Block( attributes ) )
			block.render().$el.appendTo $("#blocks")




class BlockView extends Backbone.View
	className: "block"
	
	initialize: () ->
		_.bindAll this 
		this.model.bind "change:active", this.toggleActive
		this.model.bind "change:drag_offset", this.move
		this.model.bind "change:position", this.move
		this.model.bind "change:isDragging", this.toggleZIndex

	events:
		"tap" : "ontap"
		"dragstart" : "ondragstart"
		"dragend" : "ondragend"
		"drag" : "ondrag"

	ontap: (event) ->
		console.log "tap", this.model.get('content').get('title')
		this.model.set 'active' : true

	ondragstart: (event) ->
		console.log "ondragstart", event
		this.model.set 'isDragging' : true

	ondragend: (event) ->
		console.log "ondragend", event
		this.model.set 'isDragging' : false

		this.model.positionOnGrid()

	ondrag: (event) ->
		console.log "ondrag", event
		return unless this.model.get 'isDragging'

		this.model.set "drag_offset" :
			x: event.distanceX
			y: event.distanceY

	move: () ->
		offset = 
			x: this.model.get('position').x * config.block.width + this.model.get("drag_offset").x
			y: this.model.get('position').y * config.block.height + this.model.get("drag_offset").y

		this.$el.css "-webkit-transform", "translate3d(#{offset.x}px,#{offset.y}px,0px)"

	toggleActive: () ->
		this.$el.toggleClass "active", this.model.get('active')
		
		clearTimeout this.deactivateTimeout
		that = this
		if this.model.get('active')
			this.deactivateTimeout = setTimeout () -> 
				that.model.set 'active' : false
			, 1000

	toggleZIndex: () ->
		if this.model.get 'isDragging'
			this.$el.css 'z-index', '2'
		else
			this.$el.css 'z-index', '1'

	render: () ->
		title = this.model.get('content').get('title')
		date = this.model.get('content').niceDate()

		this.$el.html """
			<div class="inner">
				<div class="label">
					<div class="date">#{date}</div>
					<h2>#{title}</h2>
				</div>
			</div>
		"""

		this.move()

		this


window.Block = Block
window.BlockView = BlockView
window.BlockCollection = BlockCollection




