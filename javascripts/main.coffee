App = ( ->

	$( ($) ->
	 	# Bootstrap application
	
		blockCollection = new BlockCollection()
		regionCollection = new RegionCollection()

		grid = new Grid(blocks: blockCollection, regions: regionCollection)
		
		gridView = new GridView(model: grid).render()

		multiTouch = new MultiTouch( el: $("body").get(0) )

		

		# create a Folder
		#folder = new FolderView( model: new Folder( content: contentCollection.first() ) )
		#folder.render().$el.appendTo $("#folders")

		window.regionCollection = regionCollection
		window.blockCollection = blockCollection
		window.grid = grid
		window.multiTouch = multiTouch
	)

)();