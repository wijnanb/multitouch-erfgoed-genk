App = ( ->

	$( ($) ->
	  # Bootstrap application

	  # Content
	  wielerlegende = new Content(
	  	title: "Wielerlegende schittert in Winterslag"
	  	date: new Date("1970-9-25")
	  )

	  # create a Block
	  new BlockView( model: new Block( content: wielerlegende ) ).render().$el.appendTo $("#blocks")

	  # create a Folder
	  new FolderView( model: new Folder( content: wielerlegende ) ).render().$el.appendTo $("#folders")
	)

)();