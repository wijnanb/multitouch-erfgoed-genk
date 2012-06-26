// Generated by CoffeeScript 1.3.3
(function() {
  var Grid, GridView,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Grid = (function(_super) {

    __extends(Grid, _super);

    function Grid() {
      return Grid.__super__.constructor.apply(this, arguments);
    }

    Grid.prototype.defaults = {
      blocks: null,
      regions: null,
      data: null
    };

    Grid.prototype.regionsChangedTimeout = null;

    Grid.prototype.initialize = function() {
      this.get("blocks").on("contentReset", this.contentReset, this);
      this.get("regions").on("change:active", this.regionsChange, this);
      return this.set({
        "data": new Array(config.grid_size.x * config.grid_size.y)
      });
    };

    Grid.prototype.contentReset = function() {
      return this.update();
    };

    Grid.prototype.update = function() {
      var activeRegions, region, _i, _len;
      this.clearRegions();
      activeRegions = this.get('regions').getActiveRegions();
      for (_i = 0, _len = activeRegions.length; _i < _len; _i++) {
        region = activeRegions[_i];
        this.setRegion(region);
      }
      this.fillWithBlocks();
      return this.trigger("change:data");
    };

    Grid.prototype.regionsChange = function(model, options) {
      var that;
      that = this;
      clearTimeout(this.regionsChangedTimeout);
      return this.regionsChangedTimeout = setTimeout(function() {
        var active;
        active = that.get('regions').getActiveRegions();
        console.log("regions", _.map(active, function(element) {
          return element.get('position');
        }));
        return that.update();
      }, 0);
    };

    Grid.prototype.val = function(x, y) {
      var data;
      data = this.get("data");
      return data[y * config.grid_size.x + x];
    };

    Grid.prototype.setVal = function(x, y, value) {
      var data;
      data = this.get("data");
      data[y * config.grid_size.x + x] = value;
      return this.set({
        "data": data
      });
    };

    Grid.prototype.setRegion = function(region) {
      var i, j, size_x, size_y, x, y, _i, _j, _ref, _ref1;
      x = config.region_positions[region.get("position")].x;
      y = config.region_positions[region.get("position")].y;
      x = Math.max(0, Math.min(x, config.grid_size.x - config.region_size.x));
      y = Math.max(0, Math.min(y, config.grid_size.y - config.region_size.y));
      size_x = x + config.region_size.x;
      size_y = y + config.region_size.y;
      for (i = _i = x, _ref = size_x - 1; x <= _ref ? _i <= _ref : _i >= _ref; i = x <= _ref ? ++_i : --_i) {
        for (j = _j = y, _ref1 = size_y - 1; y <= _ref1 ? _j <= _ref1 : _j >= _ref1; j = y <= _ref1 ? ++_j : --_j) {
          this.setVal(i, j, "r");
        }
      }
      return this.setVal(x, y, "R");
    };

    Grid.prototype.fillWithBlocks = function() {
      var bigBlocks, blocks, freeBig, freeSmall, leave_free, smallBlocks;
      blocks = this.get("blocks");
      freeBig = this.freeBigSpots();
      freeSmall = this.freeSmallSpots();
      console.log("blocks: " + blocks.length, "      free:  big " + freeBig + "   small " + freeSmall);
      leave_free = blocks.length <= freeBig ? config.grid_free.big : 0;
      bigBlocks = Math.max(0, Math.min(blocks.length, freeBig - leave_free));
      smallBlocks = blocks.length - bigBlocks;
      return console.log("big: " + bigBlocks + "  small: " + smallBlocks);
    };

    Grid.prototype.clearRegions = function() {
      var x, y, _i, _ref, _results;
      _results = [];
      for (y = _i = 0, _ref = config.grid_size.y - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; y = 0 <= _ref ? ++_i : --_i) {
        _results.push((function() {
          var _j, _ref1, _results1;
          _results1 = [];
          for (x = _j = 0, _ref1 = config.grid_size.x - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; x = 0 <= _ref1 ? ++_j : --_j) {
            if (x % 2 === 0 & y % 2 === 0) {
              _results1.push(this.setVal(x, y, "B"));
            } else {
              _results1.push(this.setVal(x, y, "b"));
            }
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    Grid.prototype.freeSmallSpots = function() {
      return (config.grid_size.x * config.grid_size.y) - this.freeBigSpots() * 4;
    };

    Grid.prototype.freeBigSpots = function() {
      var bottom, top;
      top = this.get('regions').active_top;
      bottom = this.get('regions').active_bottom;
      if (top === 0 && bottom === 0) {
        return 28;
      }
      if (top === 0 && bottom === 1) {
        return 2 * 8 + 6;
      }
      if (top === 0 && bottom === 2) {
        return 2 * 6 + 4;
      }
      if (top === 1 && bottom === 0) {
        return 2 * 8 + 6;
      }
      if (top === 1 && bottom === 1) {
        return 2 * 8 + 3;
      }
      if (top === 1 && bottom === 2) {
        return 2 * 4 + 4;
      }
      if (top === 2 && bottom === 0) {
        return 2 * 6 + 4;
      }
      if (top === 2 && bottom === 1) {
        return 2 * 4 + 4;
      }
      if (top === 2 && bottom === 2) {
        return 2 * 3 + 4;
      }
    };

    return Grid;

  })(Backbone.Model);

  GridView = (function(_super) {

    __extends(GridView, _super);

    function GridView() {
      return GridView.__super__.constructor.apply(this, arguments);
    }

    GridView.prototype.className = "grid";

    GridView.prototype.initialize = function() {
      _.bindAll(this);
      return this.model.on("change:data", this.render, this);
    };

    GridView.prototype.render = function() {
      var cell, row, table, x, y, _i, _j, _ref, _ref1;
      table = $("<table></table>");
      for (y = _i = 0, _ref = config.grid_size.y - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; y = 0 <= _ref ? ++_i : --_i) {
        row = $("<tr></tr>");
        table.append(row);
        for (x = _j = 0, _ref1 = config.grid_size.x - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; x = 0 <= _ref1 ? ++_j : --_j) {
          cell = $("<td class='col-" + x + " row-" + y + "' id='cell-" + x + "-" + y + "'></td>");
          cell.html(this.model.val(x, y));
          row.append(cell);
        }
      }
      this.$el.html(table);
      return this;
    };

    return GridView;

  })(Backbone.View);

  window.Grid = Grid;

  window.GridView = GridView;

}).call(this);
