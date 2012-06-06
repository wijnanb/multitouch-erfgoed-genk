// Generated by CoffeeScript 1.3.3
(function() {
  var App;

  App = (function() {
    return $(function($) {
      var block, contentCollection, folder;
      contentCollection = new ContentCollection();
      contentCollection.create({
        title: "Title",
        date: new Date("1981-06-07"),
        description: "A procession of Brahmins is coming this way. We must prevent their seeing us, if possible. \nThe guide unloosed the elephant and led him into a thicket, at the same time asking the travellers not to stir. \nHe held himself ready to bestride the animal at a moment's notice, should flight become necessary; but he evidently \nthought that the procession of the faithful would pass without perceiving them amid the thick foliage, in which they \nwere wholly concealed. The discordant tones of the voices and instruments drew nearer, and now droning songs mingled \nwith the sound of the tambourines and cymbals. The head of the procession soon appeared beneath the trees, a hundred \npaces away; and the strange figures who performed.",
        photo: "images/content/example_photo.jpg",
        location: {
          longitude: 50.975697,
          lattitude: 5.48501,
          zoom: 15
        },
        fiche: {
          material: "Papier",
          object: "Prentkaart"
        }
      });
      block = new BlockView({
        model: new Block({
          content: contentCollection.first()
        })
      });
      block.render().$el.appendTo($("#blocks"));
      folder = new FolderView({
        model: new Folder({
          content: contentCollection.first()
        })
      });
      folder.render().$el.appendTo($("#folders"));
      window.block = block;
      window.folder = folder;
      return window.contentCollection = contentCollection;
    });
  })();

}).call(this);
