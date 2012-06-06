class Block extends Backbone.Model
	initialize: () ->
		console.log "Block.initialize"

class BlockView extends Backbone.View
	className: "block"
	
	initialize: () ->
		console.log "BlockView.initialize"

	events:
		"click" : "click"


	click: () ->
		console.log "BlockView.click"

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

		this

class BlockCollection extends Backbone.Collection
	model: Block

	initialize: () ->
		this.fetch()

window.Block = Block
window.BlockView = BlockView
window.BlockCollection = BlockCollection




