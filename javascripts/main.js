// Generated by CoffeeScript 1.3.3
(function() {
  var App;

  App = (function() {
    return $(function($) {
      var blockCollection, grid, gridView, multiTouch, regionCollection;
      blockCollection = new BlockCollection();
      regionCollection = new RegionCollection();
      grid = new Grid({
        blocks: blockCollection,
        regions: regionCollection
      });
      if (config.debug_grid) {
        gridView = new GridView({
          model: grid
        }).render();
      }
      multiTouch = new MultiTouch({
        el: $("body").get(0)
      });
      window.regionCollection = regionCollection;
      window.blockCollection = blockCollection;
      window.grid = grid;
      window.multiTouch = multiTouch;
      return window.Ruben = "Ruben";
    });
  })();

}).call(this);
