class Folder extends Backbone.Model
	defaults:
		template: "default"
		folded: true
		vertical: 0
		horizontal: 15
		orientation: NORMAL
		position: 
			x: 0
			y: 0
	initialize: () ->
		console.log "Folder.initialize" 

	mapURL: () ->
		center = this.get("content").get("location").longitude + "," + this.get("content").get("location").lattitude
		zoom = this.get("content").get("location").zoom
		"http://maps.googleapis.com/maps/api/staticmap?center=#{center}&zoom=#{zoom}&size=640x640&sensor=false&maptype=satellite"
		"images/content/example_map.png"
	toggle: () ->
		this.set "folded": !this.get("folded")

	fold: () ->
		that = this
		clearTimeout this.hideTimeout
		this.hideTimeout = setTimeout () ->
			that.get("block").close()
		, 1500

class FolderView extends Backbone.View
	className: "folder"
	div_structure: """<div class="row row-0"><div class="row row-1up"><div class="box level0" id="box-0-0"><div class="content"></div><div class="box level1" id="box-1-0"><div class="content"></div><div class="box level2" id="box-2-0"><div class="content"></div><div class="box level3" id="box-3-0"><div class="content"></div></div></div></div></div></div><div class="box level0" id="box-0-1"><div class="content"></div><div class="box level1" id="box-1-1"><div class="content"></div><div class="box level2" id="box-2-1"><div class="content"></div><div class="box level3" id="box-3-1"><div class="content"></div></div></div></div></div><div class="row row-1down"><div class="box level0" id="box-0-2"><div class="content"></div><div class="box level1" id="box-1-2"><div class="content"></div><div class="box level2" id="box-2-2"><div class="content"></div><div class="box level3" id="box-3-2"><div class="content"></div></div></div></div></div></div></div>"""
	
	initialize: () ->
		console.log "FolderView.initialize"
		_.bindAll this
		this.model.on "change:folded", this.toggle
		this.model.get("block").on "change:opened", this.blockOpenedChanged

		this.$el.hide()
		this.$el.appendTo $("#page")
		
	events:
		"click" : "click"

	click: () ->
		console.log "FolderView.click"
		this.model.fold()
		this.model.set("folded": true)
		this.toggle()

	build: () ->
		console.log "FolderView.build"
		this.$el.html this.div_structure

		title = this.model.get('content').get('title')
		description = this.model.get('content').get('description')
		date = this.model.get('content').niceDate()

		contents = $( """
			<div class="inner">
				<div class="map"><img src="#{this.model.mapURL()}" width="800" height="800"/></div>
				<div class="fiche"></div>
				<div class="photo"><img src="#{this.model.get('content').get('photo')}"/></div>
				<div class="details">
					<h1>#{title}</h1>
					<div class="description">#{description}</div>
					<div class="date">#{date}</div>
				</div>
				<div class="related"></div>
			</div>
		""" )

		contents.addClass "template-" + this.model.get("template")

		this.$el.find(".content").each( (index, item) ->
			$(item).append contents.clone()
		)
		
	render: () ->
		console.log "FolderView.render"
		this.build()
		this.toggle()
		this

	blockOpenedChanged: () ->
		console.log("blockOpened: ", this.model.get("block").get("opened"))

		if this.model.get("block").get("opened")
			this.positionToRegion()
			this.$el.show()
			this.model.set "folded": false
		else
			this.$el.hide()
			this.model.set "folded": true

	toggle: () ->
		if this.model.get("folded")	
			this.openHorizontal(180)
			this.openVertical(180, 800)
		else
			this.openVertical(0)
			this.openHorizontal(35, 800)

	openVertical: (value, delay=200) ->
		this.$el.find(".row").css "-webkit-transition-delay", delay+"ms"

		this.$el.find(".row-1up, .row-2up, .row-3up").css "-webkit-transform", "translate3d(0px,-#{config.folder.box_size.y}px,0px) rotate3d(0,0,1,#{value}deg)"
		this.$el.find(".row-1down, .row-2down, row-3down").css "-webkit-transform", "translate3d(0px,#{config.folder.box_size.y}px,0px) rotate3d(0,0,1,-#{value}deg)"	
	
	openHorizontal: (value, delay=200) ->
		this.$el.find(".folder, .box").css "-webkit-transition-delay", delay+"ms"

		middle = (4-1) * config.folder.box_size.x / 2  * (value/180)
		x_pos = ( this.model.get("position").x + 1 ) * config.block.width
		y_pos = ( this.model.get("position").y ) * config.block.height
		value = Math.min value, 179
		half_value = value/2

		this.$el.find(".level0").css "-webkit-transform", "rotate3d(0,1,0,-#{half_value}deg)"
		this.$el.find(".level2, .level4, .level6").css "-webkit-transform", "translate3d(#{config.folder.box_size.x}px,0px,0px) rotate3d(0,1,0,-#{value}deg)"
		this.$el.find(".level1, .level3, .level5, .level7").css "-webkit-transform", "translate3d(#{config.folder.box_size.x}px,0px,0px) rotate3d(0,1,0,#{value}deg)"
		
		rotation = if this.model.get("orientation") == UPSIDE_DOWN then "180" else "0"

		console.error(this.model.get("position").x, this.model.get("position").y, "pos", x_pos, y_pos, "rotation", rotation)

		if value >= 140
			this.$el.css "-webkit-transform", "translate3d(#{x_pos}px,#{y_pos}px,0px) rotate3d(0,1,0,#{half_value}deg) rotate(#{rotation}deg)"
		else
			this.$el.css "-webkit-transform", "translate3d(#{x_pos}px,#{y_pos}px,0px) rotate3d(0,1,0,0deg) rotate(#{rotation}deg)"

	positionToRegion: () ->
		block = this.model.get("block")
		unless block.get("opened_region")
			console.warn "no opened_region set"
			return

		region_pos = block.get("opened_region").get("position")

		this.model.set("position": config.region_positions[region_pos])

		if region_pos == TOP || region_pos == TOP_LEFT || region_pos == TOP_RIGHT
			this.model.set("orientation": UPSIDE_DOWN)
		else
			this.model.set("orientation": NORMAL)

		console.log("positioned to region", region_pos, config.region_positions[region_pos], this.model.get("orientation"))

		this.render()

window.Folder = Folder
window.FolderView = FolderView