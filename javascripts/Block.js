// Generated by CoffeeScript 1.3.3
(function() {
  var Block, BlockCollection, BlockView,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Block = (function(_super) {

    __extends(Block, _super);

    function Block() {
      return Block.__super__.constructor.apply(this, arguments);
    }

    Block.prototype.LARGE = "large";

    Block.prototype.SMALL = "small";

    Block.prototype.defaults = {
      position: {
        x: 0,
        y: 0
      },
      drag_offset: {
        x: 0,
        y: 0
      },
      active: false,
      dragging: false,
      size: Block.LARGE,
      hover_position: false,
      under: false,
      transform_translation: null,
      transform_scale: null,
      transform_rotation: null,
      transition_translation: null,
      transition_scale: null
    };

    Block.prototype.initialize = function() {
      this.on("change:hover_position", this.onHover, this);
      return this.on("change:under", this.onUnder, this);
    };

    Block.prototype.nearestPosition = function() {
      var nearestPosition, pixel_position;
      pixel_position = {
        x: this.get("position").x * config.block.width + this.get("drag_offset").x,
        y: this.get("position").y * config.block.height + this.get("drag_offset").y
      };
      pixel_position.x = Math.max(0, Math.min(pixel_position.x, config.screen_width));
      pixel_position.y = Math.max(0, Math.min(pixel_position.y, config.screen_height));
      return nearestPosition = {
        x: Math.round(pixel_position.x / config.block.width),
        y: Math.round(pixel_position.y / config.block.height)
      };
    };

    Block.prototype.positionOnGrid = function() {
      this.set({
        "position": this.nearestPosition()
      });
      return this.set({
        "drag_offset": {
          x: 0,
          y: 0
        },
        silent: true
      });
    };

    Block.prototype.onHover = function() {};

    Block.prototype.onUnder = function() {
      if (this.get('under')) {
        return this.set('size', this.SMALL);
      } else {
        return this.set('size', this.LARGE);
      }
    };

    return Block;

  })(Backbone.Model);

  BlockCollection = (function(_super) {

    __extends(BlockCollection, _super);

    function BlockCollection() {
      return BlockCollection.__super__.constructor.apply(this, arguments);
    }

    BlockCollection.prototype.model = Block;

    BlockCollection.prototype.initialize = function() {
      _.bindAll(this);
      this.contentCollection = new ContentCollection();
      this.contentCollection.on("reset", this.contentReset);
      return this.on("change:hover_position", this.onHover);
    };

    BlockCollection.prototype.contentReset = function() {
      var that;
      that = this;
      return this.contentCollection.each(function(element, index, list) {
        var attributes, block, blockView;
        that.num_block_x = Math.floor(config.screen_width / config.block.width);
        that.num_block_y = Math.floor(config.screen_height / config.block.height);
        attributes = {
          content: element,
          position: {
            x: index % that.num_block_x,
            y: Math.floor(index / that.num_block_x)
          }
        };
        block = new Block(attributes);
        that.add(block);
        blockView = new BlockView({
          model: block,
          collection: that
        });
        return blockView.render().$el.appendTo($("#blocks"));
      });
    };

    BlockCollection.prototype.onHover = function(model) {
      var neighbours, over;
      if (model.get("hover_position") !== false) {
        over = this.getBlockOnPosition(model.get("hover_position"));
        if (over !== false) {
          neighbours = this.getNeighboursForBlock(over);
          _.each(neighbours, function(element, index) {
            return element.set({
              'under': true
            });
          });
          return _.each(_.difference(this.models, neighbours), function(element, index) {
            return element.set({
              'under': false
            });
          });
        }
      }
    };

    BlockCollection.prototype.getBlockOnPosition = function(position) {
      var block;
      block = false;
      this.each(function(element, index) {
        var element_position;
        if (!element.get("dragging")) {
          element_position = element.get('position');
          if (element_position.x === position.x && element_position.y === position.y) {
            block = element;
          }
        }
      });
      return block;
    };

    BlockCollection.prototype.getNeighboursForBlock = function(block) {
      var element, end_x, end_y, neighbours, position, start_x, start_y, x, y, _i, _j;
      position = block.get("position");
      start_x = Math.max(0, position.x - 1);
      end_x = Math.min(position.x + 1, this.num_block_x - 1);
      start_y = Math.max(0, position.y - 1);
      end_y = Math.min(position.y + 1, this.num_block_y - 1);
      neighbours = [];
      for (x = _i = start_x; start_x <= end_x ? _i <= end_x : _i >= end_x; x = start_x <= end_x ? ++_i : --_i) {
        for (y = _j = start_y; start_y <= end_y ? _j <= end_y : _j >= end_y; y = start_y <= end_y ? ++_j : --_j) {
          if (element = this.getBlockOnPosition({
            x: x,
            y: y
          })) {
            neighbours.push(element);
          }
        }
      }
      return neighbours;
    };

    return BlockCollection;

  })(Backbone.Collection);

  BlockView = (function(_super) {

    __extends(BlockView, _super);

    function BlockView() {
      return BlockView.__super__.constructor.apply(this, arguments);
    }

    BlockView.prototype.className = "block";

    BlockView.prototype.initialize = function() {
      _.bindAll(this);
      this.model.on("change:active", this.toggleActive);
      this.model.on("change:drag_offset", this.move);
      this.model.on("change:position", this.move);
      this.model.on("change:dragging", this.toggleZIndex);
      this.model.on("change:size", this.onChangeSize);
      this.model.on("change:transform_translation", this.transform);
      this.model.on("change:transform_scale", this.transform);
      this.model.on("change:transform_rotation", this.transform);
      return this.collection = this.options.collection;
    };

    BlockView.prototype.events = {
      "tap": "ontap",
      "dragstart": "ondragstart",
      "dragend": "ondragend",
      "drag": "ondrag"
    };

    BlockView.prototype.ontap = function(event) {
      console.log("tap", this.model.get('content').get('title'));
      return this.model.set({
        'active': true
      });
    };

    BlockView.prototype.ondragstart = function(event) {
      console.log("ondragstart", event);
      this.model.set({
        'dragging': true
      });
      return this.model.set({
        'hover_position': this.model.get("position")
      });
    };

    BlockView.prototype.ondragend = function(event) {
      console.log("ondragend", event);
      this.model.set({
        'dragging': false
      });
      this.model.positionOnGrid();
      this.model.set({
        'hover_position': false
      });
      console.log(this.collection);
      return this.collection.each(function(element, index) {
        return element.set({
          'under': false
        });
      });
    };

    BlockView.prototype.ondrag = function(event) {
      if (!this.model.get('dragging')) {
        return;
      }
      return this.model.set({
        "drag_offset": {
          x: event.distanceX,
          y: event.distanceY
        }
      });
    };

    BlockView.prototype.move = function() {
      var offset;
      offset = {
        x: this.model.get('position').x * config.block.width + this.model.get("drag_offset").x,
        y: this.model.get('position').y * config.block.height + this.model.get("drag_offset").y
      };
      this.model.set({
        "transform_translation": "" + offset.x + "px," + offset.y + "px,0px"
      });
      if (this.model.get('dragging')) {
        return this.model.set({
          'hover_position': this.model.nearestPosition()
        });
      }
    };

    BlockView.prototype.toggleActive = function() {
      var that;
      this.$el.toggleClass("active", this.model.get('active'));
      clearTimeout(this.deactivateTimeout);
      that = this;
      if (this.model.get('active')) {
        return this.deactivateTimeout = setTimeout(function() {
          return that.model.set({
            'active': false
          });
        }, 1000);
      }
    };

    BlockView.prototype.toggleZIndex = function() {
      if (this.model.get('dragging')) {
        return this.$el.css('z-index', '2');
      } else {
        return this.$el.css('z-index', '1');
      }
    };

    BlockView.prototype.render = function() {
      var date, title;
      title = this.model.get('content').get('title');
      date = this.model.get('content').niceDate();
      this.$el.html("<div class=\"inner\">\n	<div class=\"label\">\n		<div class=\"date\">" + date + "</div>\n		<h2>" + title + "</h2>\n	</div>\n</div>");
      this.move();
      return this;
    };

    BlockView.prototype.transform = function() {
      var css, rotation, scale, transition_scale, transition_translation, translation;
      css = "";
      if (scale = this.model.get("transform_scale")) {
        css += "scale(" + scale + ") ";
      }
      if (rotation = this.model.get("transform_rotation")) {
        css += "rotate(" + rotation + ") ";
      }
      if (transition_scale = this.model.get("transition_scale")) {
        this.$el.children('.inner').css("-webkit-transition", transition_scale);
      }
      this.$el.children('.inner').css("-webkit-transform", css);
      if (transition_translation = this.model.get("transition_translation")) {
        this.$el.css("-webkit-transition", transition_translation);
      }
      if (translation = this.model.get("transform_translation")) {
        return this.$el.css("-webkit-transform", "translate3d(" + translation + ") ");
      }
    };

    BlockView.prototype.onChangeSize = function() {
      if (this.model.get("size") === this.model.SMALL) {
        this.$el.addClass("small");
        this.model.set({
          "transition_scale": "all 0.5s ease-out 0s"
        });
        this.model.set({
          "transform_scale": 0.8
        });
        return this.$el.children(".inner").css("opacity", 0.5);
      } else {
        this.$el.removeClass("small");
        this.model.set({
          "transition_scale": "all 0.5s ease-out 0s"
        });
        this.model.set({
          "transform_scale": null
        });
        return this.$el.children(".inner").css("opacity", "");
      }
    };

    return BlockView;

  })(Backbone.View);

  window.Block = Block;

  window.BlockView = BlockView;

  window.BlockCollection = BlockCollection;

}).call(this);
