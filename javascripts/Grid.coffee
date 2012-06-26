class Grid extends Backbone.Model
	defaults:
		blocks: null
		regions: null
		data: null

	regionsChangedTimeout: null

	initialize: () ->
		this.get("blocks").on "contentReset", this.contentReset, this
		this.get("regions").on "change:active", this.regionsChange, this

		this.set "data" : new Array(config.grid_size.x*config.grid_size.y)
		
	contentReset: () ->
		this.update()


	update: () ->
		this.clearRegions()

		activeRegions = this.get('regions').getActiveRegions()
		this.setRegion region for region in activeRegions

		this.fillWithBlocks();

		this.trigger "change:data"


	regionsChange: (model, options) ->
		that = this
		clearTimeout this.regionsChangedTimeout
		this.regionsChangedTimeout = setTimeout () ->

			active = that.get('regions').getActiveRegions()
			console.log "regions", _.map active, (element) -> element.get('position')

			that.update()
		, 0
		
	val: (x,y) ->
		data = this.get("data")
		data[ y * config.grid_size.x + x]

	setVal: (x,y,value) ->
		data = this.get("data")
		data[ y * config.grid_size.x + x] = value

		this.set "data": data

	setRegion: (region) ->
		x = config.region_positions[region.get("position")].x
		y = config.region_positions[region.get("position")].y

		x = Math.max 0, (Math.min x, config.grid_size.x - config.region_size.x)
		y = Math.max 0, (Math.min y, config.grid_size.y - config.region_size.y)

		size_x = x+config.region_size.x
		size_y = y+config.region_size.y

		for i in [x..size_x-1]
			for j in [y..size_y-1]
				this.setVal i,j,"r"
		this.setVal x,y,"R"

	fillWithBlocks: () ->
		blocks = this.get("blocks")
		freeBig = this.freeBigSpots()
		freeSmall = this.freeSmallSpots()

		console.log "blocks: " + blocks.length, "      free:  big " + freeBig + "   small " + freeSmall

		# always leave 2 big blocks free

		leave_free = if blocks.length <= freeBig then config.grid_free.big else 0
		bigBlocks = Math.max( 0, Math.min( blocks.length, freeBig - leave_free ) )
		smallBlocks = blocks.length - bigBlocks

		console.log "big: " + bigBlocks + "  small: " + smallBlocks



	clearRegions: () ->
		for y in [0..config.grid_size.y-1]
			for x in [0..config.grid_size.x-1]
				if x%2 == 0 & y%2 == 0
					this.setVal x,y,"B"
				else
					this.setVal x,y,"b"

	freeSmallSpots: () ->
		(config.grid_size.x * config.grid_size.y) - this.freeBigSpots()*4

	freeBigSpots: () ->
		top = this.get('regions').active_top
		bottom = this.get('regions').active_bottom

		if top == 0 && bottom == 0
			return 28
		if top == 0 && bottom == 1
			return 2*8 + 6
		if top == 0 && bottom == 2
			return 2*6 + 4
		if top == 1 && bottom == 0
			return 2*8 + 6
		if top == 1 && bottom == 1
			return 2*8 + 3
		if top == 1 && bottom == 2
			return 2*4 + 4
		if top == 2 && bottom == 0
			return 2*6 + 4
		if top == 2 && bottom == 1
			return 2*4 + 4
		if top == 2 && bottom == 2
			return 2*3 + 4

class GridView extends Backbone.View
	className: "grid"

	initialize: () ->
		_.bindAll this
		this.model.on "change:data", this.render, this

	render: () ->
		table = $("<table></table>")
		for y in [0..config.grid_size.y-1]
			row = $("<tr></tr>")
			table.append(row)
			for x in [0..config.grid_size.x-1]
				cell = $("<td class='col-#{x} row-#{y}' id='cell-#{x}-#{y}'></td>")
				cell.html this.model.val(x,y)
				row.append(cell)

		this.$el.html table
		this

window.Grid = Grid
window.GridView = GridView