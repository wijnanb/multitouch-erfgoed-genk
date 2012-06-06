App = ( ->

	$( ($) ->
	 	# Bootstrap application

		# get the content
		contentCollection = new ContentCollection()

		contentCollection.create
			title: "Title"
			date: new Date("1981-06-07")
			description: """A procession of Brahmins is coming this way. We must prevent their seeing us, if possible. 
							The guide unloosed the elephant and led him into a thicket, at the same time asking the travellers not to stir. 
							He held himself ready to bestride the animal at a moment's notice, should flight become necessary; but he evidently 
							thought that the procession of the faithful would pass without perceiving them amid the thick foliage, in which they 
							were wholly concealed. The discordant tones of the voices and instruments drew nearer, and now droning songs mingled 
							with the sound of the tambourines and cymbals. The head of the procession soon appeared beneath the trees, a hundred 
							paces away; and the strange figures who performed."""
			photo: "images/content/example_photo.jpg"
			location:
				longitude: 50.975697
				lattitude: 5.48501
				zoom: 15
			fiche:
				material: "Papier"
				object: "Prentkaart"
	

		# create a Block
		block = new BlockView( model: new Block( content: contentCollection.first() ) )
		block.render().$el.appendTo $("#blocks")

		# create a Folder
		folder = new FolderView( model: new Folder( content: contentCollection.first() ) )
		folder.render().$el.appendTo $("#folders")

		window.block = block
		window.folder = folder
		window.contentCollection = contentCollection
	)

)();