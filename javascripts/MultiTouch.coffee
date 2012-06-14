class MultiTouch extends Backbone.View
	initialize: () ->
		console.log "MultiTouch.initialize"
		_.bindAll this

		this.hammer = new Hammer this.el,
				drag_min_distance: 0
				drag_horizontal: true
				drag_vertical: true
				transform: false
				hold: false
				prevent_default: true
		this.hammer.ontap = this.ontap
		this.hammer.ondragstart = this.ondragstart
		this.hammer.ondrag = this.ondrag
		this.hammer.ondragend = this.ondragend

		console.log this.hammer

		this
	
	ontap: (event) ->
		this.passEventToBlock event

	ondragstart: (event) ->
		this.passEventToBlock event

	ondrag: (event) ->
		this.passEventToBlock event

	ondragend: (event) ->
		this.passEventToBlock event

	passEventToBlock: (event) ->
		touches = event.originalEvent.touches || [event.originalEvent]
		for touch in touches
			block = $(touch.target).parents(".block")
			if block.length > 0
				$(block).trigger event


window.MultiTouch = MultiTouch