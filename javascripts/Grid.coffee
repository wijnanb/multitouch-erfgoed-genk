class Grid extends Backbone.Model
	defaults:
		blocks: null
		regions: null
		data: null

	regionsChangedTimeout: null

	initialize: () ->
		this.get("blocks").on "contentReset", this.contentReset, this
		this.get("regions").on "change:active", this.regionsChange, this
		this.get("blocks").on "change:placed", this.blockPlacedChange, this
		this.get("blocks").on "dropped", this.blockDropped, this
		
		this.set "data" : new Array(config.grid_size.x*config.grid_size.y)
		
	contentReset: () ->
		this.emptyGrid()
		this.update()

	update: () ->
		this.fillWithBlocks()

		this.trigger "change:data"

		this.get("blocks").setBlocksToGridPositions this.getGridPositions()

	regionsChange: (model, value) ->
		that = this
		clearTimeout this.regionsChangedTimeout
		this.regionsChangedTimeout = setTimeout () ->

			active = that.get('regions').getActiveRegions()
			console.log "regions", _.map active, (element) -> element.get('position')

			that.get("blocks").each (element, index) -> element.set "placed" : false

			that.emptyGrid()
		
			activeRegions = that.get('regions').getActiveRegions()
			that.setRegion region for region in activeRegions

			that.update()
		, 0 

	blockPlacedChange: (model, value) ->
		if value == false
			#remove position from grid when no longer placed
			console.log "unplaced", model
			position = model.get "position"
			this.empty position.x, position.y

			this.trigger "change:data"
				
	blockDropped: (block) ->
		console.log "Grid.blockDropped", block

		position = block.get "position"
		size = block.get "size"
		region = this.isDroppedOnRegion(block)

		console.log("region", region)

		if region != false
			console.warn "dropped on region"
			block.open(region)
		else
			block.close()
			this.setBlock position.x, position.y, size
			this.trigger "change:data" 
		
		this.findNearestPositionForNonPlacedBlocks(position)

	val: (x,y) ->
		if x < 0 or y < 0 or x > config.grid_size.x-1 or y > config.grid_size.y-1
			return false

		data = this.get("data")
		data[ y * config.grid_size.x + x ]

	empty: (x,y) ->
		if this.val(x,y) == "B"
			this.setVal x, y, "."
			this.setVal x+1, y, "."
			this.setVal x, y+1, "."
			this.setVal x+1, y+1, "."
		else if this.val(x,y) == "S"
			this.setVal x, y, "."

	isEmpty: (x,y,big = false) ->
		if big
			if this.val(x,y) == false or this.val(x+1,y) == false or this.val(x,y+1) == false or this.val(x+1,y+1) == false
				return false	
			return this.isEmpty(x,y) and this.isEmpty(x+1,y) and this.isEmpty(x,y+1) and this.isEmpty(x+1,y+1)
		else
			if this.val(x,y) == false
				return false
			return this.val(x,y) == "." or this.val(x,y) == ""

	isDroppedOnRegion: (block) ->
		x = block.get("position").x
		y = block.get("position").y

		if block.get("size") == BIG
			if this.val(x,y).toLowerCase() == "r" or this.val(x+1,y).toLowerCase() == "r" or this.val(x,y+1).toLowerCase() == "r" or this.val(x+1,y+1).toLowerCase() == "r"
				return this.get("regions").getRegionAtCoordinates("x":x, "y":y)
		else
			if this.val(x,y).toLowerCase() == "r"
				return this.get("regions").getRegionAtCoordinates("x":x, "y":y)
		false

	setVal: (x,y,value) ->
		data = this.get("data")
		data[ y * config.grid_size.x + x] = value

		this.set "data": data

	getRandomEmptySpot: (big) ->
		range_x = _.shuffle [0..config.grid_size.x-1]
		range_y = _.shuffle [0..config.grid_size.y-1]
		range = []

		for index_x in range_x
			for index_y in range_y
				x = range_x[index_x]
				y = range_y[index_y]
				range.push( "x": x, "y": y )

		this.getEmptySpot(range, big)
		
	findFreeSpotCloseTo: (center, big) ->
		range_x = [0..config.grid_size.x-1]
		range_y = [0..config.grid_size.y-1]
		range = []
		
		#order by distance
		for index_x in range_x
			for index_y in range_y
				x = range_x[index_x]
				y = range_y[index_y]
				dx = x - center.x
				dy = y - center.y
				d2 = dx*dx + dy*dy
				range.push( "x": x, "y": y, "d2": d2 )

		range = _.sortBy range, "d2" 

		console.log "findFreeSpotCloseTo", range, big
		this.getEmptySpot(range, big)

	getEmptySpot: (range, big) ->
		tries = []
		
		for position in range
			x = position.x
			y = position.y
			tries.push  "("+x+","+y+")"
			if this.isEmpty(x,y,big)
				#console.log "found with #{tries.length} tries", tries
				return {"x": x, "y": y}
		false

	findRangeClosest: (center, size) ->
		range_l = [center..0]
		range_r = [center..size-1]

		range = []
		shortest = if range_l.length > range_r.length then range_r else range_l
		longest = if range_l.length > range_r.length then range_l else range_r

		for i in [0..shortest.length*2-1]
			range[i] = if i%2 == 0 then range_l[i/2] else range_r[(i-1)/2]
		range = range.concat _.rest(longest, shortest.length)
		range = _.rest(range,1)
		
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

	setBlock: (x,y,size=BIG) ->
		if size == BIG
			x = Math.max 0, (Math.min x, config.grid_size.x - 2)
			y = Math.max 0, (Math.min y, config.grid_size.y - 2)
			this.setVal(x,y,"B")
			this.setVal(x+1,y,"b")
			this.setVal(x,y+1,"b")
			this.setVal(x+1,y+1,"b")
		else if size == SMALL
			x = Math.max 0, (Math.min x, config.grid_size.x - 1)
			y = Math.max 0, (Math.min y, config.grid_size.y - 1)
			this.setVal(x,y,"S")

	emptyGrid: () ->
		console.log "emptyGrid"
		data = new Array();
		for i in [0..(config.grid_size.x*config.grid_size.y-1)]
			data[i] = "."
		this.set "data" : data

	fillWithBlocks: () ->
		blocks = this.get("blocks").getBlocksOrdered true #non-placed blocks only

		return if blocks.length == 0

		alreadyPlaced = this.get("blocks").length - blocks.length

		maxFreeBig = Math.min(blocks.length, this.freeBigSpots() )
		maxFreeSmall = this.freeSmallSpots()

		bigBlocks = Math.min blocks.length, Math.floor (maxFreeSmall - blocks.length) / (4-1)
		smallBlocks = Math.max 0, Math.min blocks.length - bigBlocks, maxFreeSmall - bigBlocks*4

		console.log "fill with blocks", "big: " + bigBlocks, "small: " + smallBlocks

		# big first
		for i in [0..bigBlocks-1]
			spot = this.getRandomEmptySpot(true)
			unless spot == false
				this.setBlock spot.x, spot.y, BIG
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
				this.setBlock spot.x, spot.y, SMALL
			else
				# no free small spots found
				console.log "not enough free small spots found"
				break

	findNearestPositionForNonPlacedBlocks: (center) ->
		nonPlacedBlocks = this.get("blocks").getNonPlacedBlocks()

		for block in nonPlacedBlocks
			position = this.findFreeSpotCloseTo(center, block.get("size") == BIG)

			if position == false
				console.warn "cannot find big spot, shrink the block"
				block.set("size" : SMALL)
				position = this.findFreeSpotCloseTo(center, block.get("size") == BIG)

			this.setBlock position.x, position.y, block.get("size")
			this.trigger "change:data"
			block.place position

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