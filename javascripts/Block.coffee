class Block extends Backbone.Model
	defaults:
		position:
			x: 0
			y: 0
	initialize: () ->
		console.log "Block.initialize"

class BlockCollection extends Backbone.Collection
	model: Block

	initialize: () ->
		this.contentCollection = new ContentCollection()
		this.contentCollection.bind "reset", this.reset, this

	reset: () ->
		console.log "BlockCollection.reset"
		this.contentCollection.each (element,index,list) ->
			console.log index + ": " + element.get("title")

			num_block_x = Math.floor config.screen_width / config.block.width
			
			attributes = 
				content: element
				position:
					x: index % num_block_x
					y: Math.floor index / num_block_x

			block = new BlockView( model: new Block( attributes ) )
			block.render().$el.appendTo $("#blocks")




class BlockView extends Backbone.View
	className: "block"
	
	initialize: () ->
		console.log "BlockView.initialize"

		_.bindAll this

		hammer = new Hammer this.el,
				drag_min_distance: 0
				drag_horizontal: true
				drag_vertical: true
				transform: false
				hold: false
				prevent_default: true
		hammer.ontap = this.ontap
		hammer.ondragstart = this.ondragstart
		hammer.ondrag = this.ondrag
		hammer.ondragend = this.ondragend

		this
	
	ontap: () ->
		console.log "tap", this

	ondragstart: () ->
		console.log "dragstart", this

	ondrag: () ->
		console.log "drag", this

	ondragend: () ->
		console.log "dragend", this

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

		this.$el.css "left", this.model.get('position').x * config.block.width + "px"
		this.$el.css "top", this.model.get('position').y * config.block.height + "px"

		this


window.Block = Block
window.BlockView = BlockView
window.BlockCollection = BlockCollection




