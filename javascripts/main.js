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
      gridView = new GridView({
        model: grid,
        el: $("#gridView")
      }).render();
      multiTouch = new MultiTouch({
        el: $("body").get(0)
      });
      window.regionCollection = regionCollection;
      window.blockCollection = blockCollection;
      window.grid = grid;
      return window.multiTouch = multiTouch;
    });
  })();

}).call(this);
