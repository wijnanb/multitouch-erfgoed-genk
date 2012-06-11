App = ( ->

	$( ($) ->
	 	# Bootstrap application

		
		# create blocks
		blockCollection = new BlockCollection()

		#block = new BlockView( model: new Block( content: contentCollection.first() ) )
		#block.render().$el.appendTo $("#blocks")

		# create a Folder
		#folder = new FolderView( model: new Folder( content: contentCollection.first() ) )
		#folder.render().$el.appendTo $("#folders")

		#window.folder = folder
		window.blockCollection = blockCollection
	)

)();