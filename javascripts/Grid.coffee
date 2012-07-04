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
		this.emptyGrid()
		
		activeRegions = this.get('regions').getActiveRegions()
		this.setRegion region for region in activeRegions

		this.fillWithBlocks()

		this.trigger "change:data"
		console.log "grid positions: ", this.getGridPositions()

		this.get("blocks").setBlocksToGridPositions this.getGridPositions()

	regionsChange: (model, options) ->
		that = this
		clearTimeout this.regionsChangedTimeout
		this.regionsChangedTimeout = setTimeout () ->

			active = that.get('regions').getActiveRegions()
			console.log "regions", _.map active, (element) -> element.get('position')

			that.update()
		, 0 

		
	val: (x,y) ->
		if x < 0 or y < 0 or x > config.grid_size.x-1 or y > config.grid_size.y-1
			return false

		data = this.get("data")
		data[ y * config.grid_size.x + x ]

	isEmpty: (x,y,big = false) ->
		if big
			if this.val(x,y) == false or this.val(x+1,y) == false or this.val(x,y+1) == false or this.val(x+1,y+1) == false
				return false	
			return this.isEmpty(x,y) and this.isEmpty(x+1,y) and this.isEmpty(x,y+1) and this.isEmpty(x+1,y+1)
		else
			if this.val(x,y) == false
				return false
			return this.val(x,y) == "." or this.val(x,y) == ""

	setVal: (x,y,value) ->
		data = this.get("data")
		data[ y * config.grid_size.x + x] = value

		this.set "data": data

	getRandomEmptySpot: (big) ->
		cnt = 0
		try_x = _.shuffle [0..config.grid_size.x-1]
		try_y = _.shuffle [0..config.grid_size.y-1]

		for i in try_x
			for j in try_y
				x = try_x[i]
				y = try_y[j]
				cnt++
				#console.log "try", x, y, this.isEmpty(x,y,big)
				if this.isEmpty(x,y,big)
					#console.log "found with #{cnt} tries"
					return {"x": x, "y": y}
		false

		
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

	emptyGrid: () ->
		console.log "emptyGrid"
		data = new Array();
		for i in [0..(config.grid_size.x*config.grid_size.y-1)]
			data[i] = "."
		this.set "data" : data

	fillWithBlocks: () ->
		blocks = this.get("blocks")
		maxFreeBig = Math.min(blocks.length, this.freeBigSpots() )
		maxFreeSmall = this.freeSmallSpots()

		bigBlocks = Math.min blocks.length, Math.floor (maxFreeSmall - blocks.length) / (4-1)
		smallBlocks = Math.max 0, Math.min blocks.length - bigBlocks, maxFreeSmall - bigBlocks*4

		# big first
		for i in [0..bigBlocks-1]
			spot = this.getRandomEmptySpot(true)
			unless spot == false
				this.setVal(spot.x,spot.y,"B")
				this.setVal(spot.x+1,spot.y,"b")
				this.setVal(spot.x,spot.y+1,"b")
				this.setVal(spot.x+1,spot.y+1,"b")
			else
				# no free big spots found
				console.log "not enough free big spots found"
				bigBlocks = i
				break
		
		# small blocks second
		smallBlocks = blocks.length - bigBlocks
		for i in [0..smallBlocks-1]
			spot = this.getRandomEmptySpot()
			unless spot == false
				this.setVal(spot.x,spot.y,"S")
			else
				# no free small spots found
				console.log "not enough free small spots found"
				break


	clearRegions: () ->
		for y in [0..config.grid_size.y-1]
			for x in [0..config.grid_size.x-1]
				if x%2 == 0 & y%2 == 0
					this.setVal x,y,"B"
				else
					this.setVal x,y,"b"

	freeSmallSpots: () ->
		(config.grid_size.x * config.grid_size.y) - this.numActiveRegions()*(config.region_size.x*config.region_size.y)

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

	getGridPositions: () ->
		positions = []

		for x in [0..config.grid_size.x-1]
			for y in [0..config.grid_size.y-1]
				value = this.val x,y
				if _.include ["B","S"], value
					positions.push { "x": x, "y": y, "value": value }
		positions

	numActiveRegions: () ->
		this.get('regions').getActiveRegions().length

class GridView extends Backbone.View
	className: "grid"
	id: "gridView"

	initialize: () ->
		_.bindAll this
		this.model.on "change:data", this.render, this
		this.$el.insertAfter $("#page")

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