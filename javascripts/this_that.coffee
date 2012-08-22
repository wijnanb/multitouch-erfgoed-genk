App = ( ->
	# closure


	init = () ->
		#closure

		reg1 = 1 
		reg2 = 2
		that = this

		console.log "this", this

		for index in [0,1,2,3,4]
			console.log "index", index
			
			( ->
				#closure

				that_index = index

				setTimeout () ->
					# closure

					console.log "this", this, "that", that
					console.log "reg1", reg1
					console.log "index", that_index

				, index * 1000
			)();
	
	return "init" : init
)();

App.init()