class Grid extends Backbone.Model
	defaults:
		blocks: null
		regions: null
		data: null

	initialize: () ->
		this.get("blocks").on "contentReset", this.contentReset, this
		this.get("regions").on "change:active", this.regionsChange, this

		this.data = new Array()

	contentReset: () ->
		this.fillWithBlocks()

	fillWithBlocks: () ->
		for i in [0..this.get("blocks").length]
			#do something
			this

	regionsChange: () ->
		
	val: (x,y) ->
		data = this.get("data")
		data[ y * config.grid_size.x + x]

	setVal: (x,y,value) ->
		data = this.get("data")
		data[ y * config.grid_size.x + x] = value

		this.set "data": data
		this.trigger "change:data"

	setRegion: (x,y) ->
		x = Math.max 0, (Math.min x, config.grid_size.x - config.region_size.x)
		y = Math.max 0, (Math.min y, config.grid_size.y - config.region_size.y)

		for i in [x..x+config.region_size.x-1]
			for j in [y..y+config.region_size.y-1]
				this.setVal i,j,"r"
		this.setVal x,y,"R"


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