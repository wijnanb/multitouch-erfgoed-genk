class Block extends Backbone.Model
	defaults:
		placed: false
		position:
			x: 0
			y: 0
		drag_offset:
			x: 0
			y: 0
		active: false
		dragging: false
		size: BIG
		hover_position: false
		under: false
		transform_translation: null
		transform_scale: null
		transform_rotation: null
		transition_translation: "-webkit-transform 0.4s ease-in-out"
		transition_scale: null
		empty: true
		opened: false
		opened_region: null
		orientation: NORMAL

	initialize: () ->
		this.on "change:hover_position", this.onHover, this
		this.on "change:under", this.onUnder, this
		this.on "change:dragging", this.onDragging, this
		this.on "change:size", this.onSizeChanged, this
		this.on "change:opened", this.onOpenedChanged, this
		this.on "change:orientation", this.onOrientationChanged, this

		
	nearestPosition: () ->
		pixel_position = 
			x: this.get("position").x * config.block.width + this.get("drag_offset").x
			y: this.get("position").y * config.block.height + this.get("drag_offset").y

		pixel_position.x = Math.max 0, Math.min( pixel_position.x, config.screen_width )
		pixel_position.y = Math.max 0, Math.min( pixel_position.y, config.screen_height )

		nearestPosition =
			x: Math.round pixel_position.x / config.block.width
			y: Math.round pixel_position.y / config.block.height

	place: (position=false, size=false) ->
		if !position
			position = this.nearestPosition()
		if size then this.set "size" : size

		this.set "position" : position
		this.set "drag_offset": { x:0, y:0 }, silent: true
		this.set "placed" : true

	largeAllowed: () ->
		# return false when not enough space for large
		true

	onDragging: () ->
		#console.log("model.onHover")
		this.set "transition_translation", if this.get "dragging" then "" else "-webkit-transform 0.4s ease-in-out"			

	onHover: (model, value, options) ->
		console.log "onHover", this.get("drag_offset").x, this.get("drag_offset").y

		if this.get("drag_offset").y > 0
			this.set "orientation" : NORMAL
		else if this.get("drag_offset").y < 0
			this.set "orientation" : UPSIDE_DOWN

	onSizeChanged: () ->
		if this.get("size") == BIG
			unless this.largeAllowed() then this.set("size" : SMALL)

	onOpenedChanged: () ->
		console.log "opened: ", this.get "opened"

	open: (region) ->
		this.set "opened_region" : region
		this.set "opened" : true
		
	close: () ->
		this.set "opened" : false

	onOrientationChanged: () ->
		if this.get("orientation") == UPSIDE_DOWN
			console.warn "UPSIDE_DOWN"
			this.set "transform_rotation", "180deg"
		else
			this.set "transform_rotation", ""

class BlockCollection extends Backbone.Collection
	model: Block
	
	initialize: () ->
		_.bindAll this
		this.contentCollection = new ContentCollection()
		this.contentCollection.on "reset", this.contentReset
		this.on "change:hover_position", this.onHover
		this.on "dropped", this.onDropped, this

	contentReset: () ->
		that = this
		this.contentCollection.each (element,index,list) ->
			attributes =
				content: element
				position:
					x: index % config.grid_size.x
					y: Math.floor index / config.grid_size.x

			block = new Block(attributes)
			blockView = new BlockView( model: block, collection: that ).render()
			that.add block

			folder = new Folder( "content": element, "block": block );
			folderView = new FolderView( model: folder ).render()
		
		this.trigger "contentReset"

	onHover: (model) ->
		affected = 	this.getAffectedBlocksUnderHoverPosition model

		_.each affected, (element, index) ->
			element.set 'under' : true
		_.each _.difference(this.models, affected), (element, index) ->
			element.set 'under' : false

	onDropped: (model) ->
		console.log "block.onDropped"

		affected = this.getAffectedBlocksUnderHoverPosition model
		#console.log "affected", affected

		_.each affected, (element, index) -> element.set "placed" : false

		model.place()
		model.set 'hover_position' : false

	getAffectedBlocksUnderHoverPosition: (model) ->
		return [] if model.get("hover_position") == false

		over = this.getBlockOnPosition( model.get("hover_position") )

		if BIG == model.get "size"
			affected = this.getNeightboursUnderBigBlock model.nearestPosition()
		else if over
			affected = [over]
		else
			affected = []

	getBlockOnPosition: (position) ->
		block = false
		this.each (element, index) ->
			unless element.get "dragging"
				element_position = element.get 'position'
				if element_position.x == position.x && element_position.y == position.y
					block = element
				if BIG == element.get "size"
					if (element_position.x == position.x-1 && element_position.y == position.y) or (element_position.x == position.x && element_position.y == position.y-1)	or (element_position.x == position.x-1 && element_position.y == position.y-1)
						block = element
		block

	getNeightboursForPosition: (position) ->
		start_x = Math.max 0, position.x - 1
		end_x = Math.min position.x + 1, config.grid_size.x - 1
		start_y = Math.max 0, position.y - 1
		end_y = Math.min position.y + 1, config.grid_size.y - 1 

		neighbours = []

		for x in [start_x..end_x]
			for y in [start_y..end_y]
				if element = this.getBlockOnPosition { x: x, y: y }
					neighbours.push element

		#ignore duplicates
		_.uniq neighbours

	getNeightboursUnderBigBlock: (position) ->
		start_x = position.x
		end_x = Math.min position.x + 1, config.grid_size.x - 1
		start_y = position.y
		end_y = Math.min position.y + 1, config.grid_size.y - 1 

		neighbours = []

		for x in [start_x..end_x]
			for y in [start_y..end_y]
				if element = this.getBlockOnPosition { x: x, y: y }
					neighbours.push element

		#ignore duplicates
		_.uniq neighbours

	setBlocksToGridPositions: (positions) ->
		that = this
		blocks = this.getBlocksOrdered true

		#filter free positions
		positions = _.reject positions, (element, index) ->
			that.find (block, i) -> block.get("placed") && block.get("position").x == element.x && block.get("position").y == element.y

		console.log "filtered positions", positions

		_.each blocks, (element, index) ->
			position = positions[index]
			size = if position.value == "B" then BIG else SMALL
			element.place position, size

	getBlocksOrdered: (nonPlacedOnly=false) ->
		blocks = if nonPlacedOnly
				this.filter (element, index) ->  !element.get("placed")
			else this.models

		console.log blocks
		
		blocks.sort (a,b) ->
			pos_a = a.get "position" 
			pos_b = b.get "position"

			if (pos_a.x < pos_b.x) then return -1
			if (pos_a.x > pos_b.x) then return 1

			if (pos_a.x == pos_b.x)
				if (pos_a.y < pos_b.y) then return -1
				if (pos_a.y > pos_b.y) then return 1
				if (pos_a.y == pos_b.y) then return 0
	
	getNonPlacedBlocks: () ->
		this.filter (element, index) ->  !element.get("placed") && !element.get("opened")






class BlockView extends Backbone.View
	className: "block"
	
	initialize: () ->
		_.bindAll this 
		this.model.on "change:active", this.toggleActive
		this.model.on "change:drag_offset", this.move
		this.model.on "change:position", this.move
		this.model.on "change:dragging", this.toggleZIndex
		this.model.on "change:under", this.onChangeUnder
		this.model.on "change:size", this.onChangeSize
		this.model.on "change:transform_translation", this.transform
		this.model.on "change:transform_scale", this.transform
		this.model.on "change:transform_rotation", this.transform
		this.model.on "change:transition_translation", this.transform
		this.model.on "change:transition_scale", this.transform
		this.model.on "change:opened", this.onOpenedChanged

		this.collection = this.options.collection

		this.$el.appendTo $("#page")

	events:
		"tap" : "ontap"
		"dragstart" : "ondragstart"
		"dragend" : "ondragend"
		"drag" : "ondrag"

	ontap: (event) ->
		console.log "tap", this.model.get('content').get('title')
		this.model.set 'active' : true
		this.model.set "size" : if BIG == this.model.get "size" then SMALL else BIG

	ondragstart: (event) ->
		console.log "ondragstart", event
		this.model.set 'dragging' : true
		this.model.set 'hover_position' : this.model.get("position")
		this.model.set 'placed' : false

	ondragend: (event) ->
		console.log "ondragend", event
		this.model.set 'dragging' : false

		this.model.trigger "dropped", this.model

		#console.log this.collection
		#this.collection.each (element, index) ->
		#	element.set 'under' : false

	ondrag: (event) ->
		#console.log "ondrag", event
		return unless this.model.get 'dragging'

		this.model.set "drag_offset" :
			x: event.distanceX
			y: event.distanceY

	move: () ->
		offset = 
			x: this.model.get('position').x * config.block.width + this.model.get("drag_offset").x
			y: this.model.get('position').y * config.block.height + this.model.get("drag_offset").y

		this.model.set "transform_translation" : "#{offset.x}px,#{offset.y}px,0px"

		if this.model.get('dragging') then this.model.set 'hover_position' : this.model.nearestPosition()

	toggleActive: () ->
		this.$el.toggleClass "active", this.model.get('active')
		
		clearTimeout this.deactivateTimeout
		that = this
		if this.model.get('active')
			this.deactivateTimeout = setTimeout () -> 
				that.model.set 'active' : false
			, 1000

	toggleZIndex: () ->
		if this.model.get 'dragging'
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

	transform: () ->
		css = ""

		if scale = this.model.get "transform_scale"
			css += "scale(#{scale}) "

		if rotation = this.model.get "transform_rotation"
			css += "rotate(#{rotation}) "

		transition_scale = this.model.get "transition_scale" || ""
		this.$el.children('.inner').css "-webkit-transition", transition_scale

		this.$el.children('.inner').css "-webkit-transform", css

		transition_translation = this.model.get "transition_translation" || ""
		this.$el.css "-webkit-transition", transition_translation

		translation = this.model.get "transform_translation" || ""
		this.$el.css "-webkit-transform", "translate3d(#{translation}) "
		

	onChangeSize: () ->
		this.model.set "transition_scale" : "all 0.1s ease-out 0s"
		this.setScale()

	onChangeUnder: () ->
		this.model.set "transition_scale" : "all 0.5s ease-out 0s"
		this.setScale()
		
	setScale: () ->
		small = this.model.get("size") == SMALL
		this.$el.toggleClass "small", small
		this.$el.children(".inner").css "-webkit-transform-origin", if small then  "top left" else ""

		if this.model.get("under")
			this.model.set "transform_scale" : if small then 0.4 else 0.8
			this.$el.children(".inner").css "opacity", 0.5
		else
			this.model.set "transform_scale" : if small then 0.5 else null
			this.$el.children(".inner").css "opacity", ""

	onOpenedChanged: () ->
		if this.model.get("opened")
			this.$el.hide()
		else
			this.$el.show()


window.Block = Block
window.BlockView = BlockView
window.BlockCollection = BlockCollection




