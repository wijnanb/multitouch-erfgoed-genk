class Region extends Backbone.Model
	defaults:
		position: null
		active: false
		sensor: false

	initialize: () ->
		this.on "change:hover_position", this.onHover, this
		this.on "change:under", this.onUnder, this
		this.on "change:active", this.onActiveChanged, this

	toggleSensor: () ->
		this.set "sensor" : !this.get("sensor")

	onActiveChanged: () ->
		#console.log "onActiveChanged"





class RegionCollection extends Backbone.Collection
	model: Region
	active_top: 0
	active_bottom: 0
	sensors: []
	positions: [TOP_LEFT, TOP, TOP_RIGHT, BOTTOM_LEFT, BOTTOM, BOTTOM_RIGHT]
	
	initialize: () ->
		_.bindAll this
		this.reset()
		this.on "change:sensor", this.onSensorChanged, this
	
	reset: () ->
		for position in this.positions
			region = new Region 'position' : position
			this.add region

			new RegionView( model: region ).render()
			new RegionButton( model: region ).render()


	onSensorChanged: (model) ->
		oldSensors = this.sensors
		this.sensors = _.map this.getActiveSensors(), (element) -> element.get('position')

		detected_at_top =  _.include(this.sensors, TOP)   ||   _.include(this.sensors, TOP_LEFT)  ||    _.include(this.sensors, TOP_RIGHT)
		detected_at_top_left_right = _.include(this.sensors, TOP_LEFT)  &&    _.include(this.sensors, TOP_RIGHT)
		
		if detected_at_top
			if detected_at_top_left_right
				if 2 != this.active_top
					move_center_to = if _.include(oldSensors, TOP_LEFT) then TOP_LEFT else TOP_RIGHT
					this.active_top = 2
					this.toggleActiveOnRegions
						TOP_LEFT : true
						TOP : false
						TOP_RIGHT : true
			else
				if 1 != this.active_top
					this.active_top = 1
					this.toggleActiveOnRegions
						TOP_LEFT : false
						TOP : true
						TOP_RIGHT : false
		else
			if 0 != this.active_top
				this.active_top = 0
				this.toggleActiveOnRegions
						TOP_LEFT : false
						TOP : false
						TOP_RIGHT : false

		detected_at_bottom =  _.include(this.sensors, BOTTOM)   ||   _.include(this.sensors, BOTTOM_LEFT)  ||    _.include(this.sensors, BOTTOM_RIGHT)
		detected_at_bottom_left_right = _.include(this.sensors, BOTTOM_LEFT)  &&    _.include(this.sensors, BOTTOM_RIGHT)
		
		if detected_at_bottom
			if detected_at_bottom_left_right
				if 2 != this.active_bottom
					move_center_to = if _.include(oldSensors, BOTTOM_LEFT) then BOTTOM_LEFT else BOTTOM_RIGHT
					this.active_bottom = 2
					this.toggleActiveOnRegions
						BOTTOM_LEFT : true
						BOTTOM : false
						BOTTOM_RIGHT : true
			else
				if 1 != this.active_bottom
					this.active_bottom = 1
					this.toggleActiveOnRegions
						BOTTOM_LEFT : false
						BOTTOM : true
						BOTTOM_RIGHT : false
		else
			if 0 != this.active_bottom
				this.active_bottom = 0
				this.toggleActiveOnRegions
						BOTTOM_LEFT : false
						BOTTOM : false
						BOTTOM_RIGHT : false		

		
	getActiveRegions: () ->
		activeRegions = this.filter (element)-> element.get('active')

	getActiveSensors: () ->
		activeSensors = this.filter (element)-> element.get('sensor')

	getRegionAtPosition: (position) ->
		this.find (element) -> element.get('position') == position

	getRegionAtCoordinates: (coords) ->
		result = false

		_.each this.getActiveRegions(), (element, index) -> 
			region_pos = config.region_positions[ element.get('position') ]

			console.log element, region_pos, coords

			if coords.x >= region_pos.x && coords.x < region_pos.x + config.region_size.x
				if coords.y >= region_pos.y && coords.y < region_pos.y + config.region_size.y
					result = element
		result


	toggleActiveOnRegions: (regions) ->
		changed = false
		for position, value of regions
			region = this.getRegionAtPosition(position)
			if region
				region.set('active' : value)
			

class RegionView extends Backbone.View
	className: "region"
	
	initialize: () ->
		_.bindAll this
		this.collection = this.options.collection
		this.model.on "change:active", this.render

		this.$el.appendTo $("#page")
		this.$el.addClass this.model.get "position"

	render: () ->
		this.$el.toggleClass "active", this.model.get "active"
		this






class RegionButton extends Backbone.View
	model: Region
	className: "region-button"

	events:
		"tap" : "ontap"

	initialize: () ->
		_.bindAll this
		this.collection = this.options.collection
		this.model.on "change:sensor", this.onSensorChanged
		this.$el.addClass this.model.get "position"
		this.$el.appendTo $("#regions")

	render: () ->
		this.$el.html """
			<div class="piece horizontal"></div>
			<div class="piece vertical"></div>
		"""
		
		this

	ontap: (event) ->
		this.model.toggleSensor()


	onSensorChanged: () ->
		this.$el.toggleClass "active", this.model.get("sensor")





window.Region = Region
window.RegionCollection = RegionCollection
window.RegionView = RegionView
window.RegionButton = RegionButton





