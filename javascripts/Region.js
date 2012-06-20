// Generated by CoffeeScript 1.3.3
(function() {
  var Region, RegionButton, RegionCollection, RegionView,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Region = (function(_super) {

    __extends(Region, _super);

    function Region() {
      return Region.__super__.constructor.apply(this, arguments);
    }

    Region.TOP_LEFT = "top-left";

    Region.TOP = "top";

    Region.TOP_RIGHT = "top-right";

    Region.BOTTOM_LEFT = "bottom-left";

    Region.BOTTOM = "bottom";

    Region.BOTTOM_RIGHT = "bottom-right";

    Region.POSITIONS = [Region.TOP_LEFT, Region.TOP, Region.TOP_RIGHT, Region.BOTTOM_LEFT, Region.BOTTOM, Region.BOTTOM_RIGHT];

    Region.prototype.defaults = {
      position: null,
      active: false
    };

    Region.prototype.initialize = function() {
      this.on("change:hover_position", this.onHover, this);
      return this.on("change:under", this.onUnder, this);
    };

    Region.prototype.toggleActive = function() {
      return this.set({
        "active": !this.get("active")
      });
    };

    return Region;

  })(Backbone.Model);

  RegionCollection = (function(_super) {

    __extends(RegionCollection, _super);

    function RegionCollection() {
      return RegionCollection.__super__.constructor.apply(this, arguments);
    }

    RegionCollection.prototype.model = Region;

    RegionCollection.prototype.initialize = function() {
      _.bindAll(this);
      return this.reset();
    };

    RegionCollection.prototype.reset = function() {
      var button, position, region, _i, _len, _ref, _results;
      console.log(Region.POSITIONS);
      _ref = Region.POSITIONS;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        position = _ref[_i];
        console.log(position);
        region = new Region({
          position: position
        });
        button = new RegionButton({
          model: region
        });
        _results.push(button.render().$el.appendTo($("#regions")));
      }
      return _results;
    };

    return RegionCollection;

  })(Backbone.Collection);

  RegionView = (function(_super) {

    __extends(RegionView, _super);

    function RegionView() {
      return RegionView.__super__.constructor.apply(this, arguments);
    }

    RegionView.prototype.className = "region";

    RegionView.prototype.initialize = function() {
      _.bindAll(this);
      return this.collection = this.options.collection;
    };

    RegionView.prototype.render = function() {
      return this;
    };

    return RegionView;

  })(Backbone.View);

  RegionButton = (function(_super) {

    __extends(RegionButton, _super);

    function RegionButton() {
      return RegionButton.__super__.constructor.apply(this, arguments);
    }

    RegionButton.prototype.model = Region;

    RegionButton.prototype.className = "region-button";

    RegionButton.prototype.events = {
      "tap": "ontap"
    };

    RegionButton.prototype.initialize = function() {
      _.bindAll(this);
      this.collection = this.options.collection;
      return this.model.on("change:active", this.onActiveChanged);
    };

    RegionButton.prototype.render = function() {
      this.$el.addClass(this.model.get("position"));
      this.$el.html("<div class=\"piece horizontal\"></div>\n<div class=\"piece vertical\"></div>");
      return this;
    };

    RegionButton.prototype.ontap = function(event) {
      return this.model.toggleActive();
    };

    RegionButton.prototype.onActiveChanged = function() {
      return this.$el.toggleClass("active", this.model.get("active"));
    };

    return RegionButton;

  })(Backbone.View);

  window.Region = Region;

  window.RegionCollection = RegionCollection;

  window.RegionView = RegionView;

  window.RegionButton = RegionButton;

}).call(this);
