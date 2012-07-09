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

    Block.prototype.defaults = {
      placed: false,
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
      size: BIG,
      hover_position: false,
      under: false,
      transform_translation: null,
      transform_scale: null,
      transform_rotation: null,
      transition_translation: "-webkit-transform 0.4s ease-in-out",
      transition_scale: null,
      empty: true
    };

    Block.prototype.initialize = function() {
      this.on("change:hover_position", this.onHover, this);
      this.on("change:under", this.onUnder, this);
      return this.on("change:dragging", this.onDragging, this);
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

    Block.prototype.place = function(position, size) {
      if (position == null) {
        position = false;
      }
      if (size == null) {
        size = false;
      }
      if (!position) {
        position = this.nearestPosition();
      }
      if (size) {
        this.set({
          "size": size
        });
      }
      this.set({
        "position": position
      });
      this.set({
        "drag_offset": {
          x: 0,
          y: 0
        },
        silent: true
      });
      return this.set({
        "placed": true
      });
    };

    Block.prototype.onDragging = function() {
      return this.set("transition_translation", this.get("dragging") ? "" : "-webkit-transform 0.4s ease-in-out");
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
      this.on("change:hover_position", this.onHover);
      return this.on("dropped", this.onDropped, this);
    };

    BlockCollection.prototype.contentReset = function() {
      var that;
      that = this;
      this.contentCollection.each(function(element, index, list) {
        var attributes, block, blockView;
        attributes = {
          content: element,
          position: {
            x: index % config.grid_size.x,
            y: Math.floor(index / config.grid_size.x)
          }
        };
        block = new Block(attributes);
        that.add(block);
        return blockView = new BlockView({
          model: block,
          collection: that
        }).render();
      });
      return this.trigger("contentReset");
    };

    BlockCollection.prototype.onHover = function(model) {
      var affected;
      affected = this.getAffectedBlocksUnderHoverPosition(model);
      _.each(affected, function(element, index) {
        return element.set({
          'under': true
        });
      });
      return _.each(_.difference(this.models, affected), function(element, index) {
        return element.set({
          'under': false
        });
      });
    };

    BlockCollection.prototype.onDropped = function(model) {
      var affected;
      console.log("block.onDropped");
      affected = this.getAffectedBlocksUnderHoverPosition(model);
      _.each(affected, function(element, index) {
        return element.set({
          "placed": false
        });
      });
      model.place();
      return model.set({
        'hover_position': false
      });
    };

    BlockCollection.prototype.getAffectedBlocksUnderHoverPosition = function(model) {
      var affected, over;
      if (model.get("hover_position") === false) {
        return [];
      }
      over = this.getBlockOnPosition(model.get("hover_position"));
      if (BIG === model.get("size")) {
        return affected = this.getNeightboursUnderBigBlock(model.nearestPosition());
      } else if (over) {
        return affected = [over];
      } else {
        return affected = [];
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
          if (BIG === element.get("size")) {
            if ((element_position.x === position.x - 1 && element_position.y === position.y) || (element_position.x === position.x && element_position.y === position.y - 1) || (element_position.x === position.x - 1 && element_position.y === position.y - 1)) {
              return block = element;
            }
          }
        }
      });
      return block;
    };

    BlockCollection.prototype.getNeightboursForPosition = function(position) {
      var element, end_x, end_y, neighbours, start_x, start_y, x, y, _i, _j;
      start_x = Math.max(0, position.x - 1);
      end_x = Math.min(position.x + 1, config.grid_size.x - 1);
      start_y = Math.max(0, position.y - 1);
      end_y = Math.min(position.y + 1, config.grid_size.y - 1);
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
      return _.uniq(neighbours);
    };

    BlockCollection.prototype.getNeightboursUnderBigBlock = function(position) {
      var element, end_x, end_y, neighbours, start_x, start_y, x, y, _i, _j;
      start_x = position.x;
      end_x = Math.min(position.x + 1, config.grid_size.x - 1);
      start_y = position.y;
      end_y = Math.min(position.y + 1, config.grid_size.y - 1);
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
      return _.uniq(neighbours);
    };

    BlockCollection.prototype.setBlocksToGridPositions = function(positions) {
      var blocks, that;
      that = this;
      blocks = this.getBlocksOrdered(true);
      positions = _.reject(positions, function(element, index) {
        return that.find(function(block, i) {
          return block.get("placed") && block.get("position").x === element.x && block.get("position").y === element.y;
        });
      });
      console.log("filtered positions", positions);
      return _.each(blocks, function(element, index) {
        var position, size;
        position = positions[index];
        size = position.value === "B" ? BIG : SMALL;
        return element.place(position, size);
      });
    };

    BlockCollection.prototype.getBlocksOrdered = function(nonPlacedOnly) {
      var blocks;
      if (nonPlacedOnly == null) {
        nonPlacedOnly = false;
      }
      blocks = nonPlacedOnly ? this.filter(function(element, index) {
        return !element.get("placed");
      }) : this.models;
      console.log(blocks);
      return blocks.sort(function(a, b) {
        var pos_a, pos_b;
        pos_a = a.get("position");
        pos_b = b.get("position");
        if (pos_a.x < pos_b.x) {
          return -1;
        }
        if (pos_a.x > pos_b.x) {
          return 1;
        }
        if (pos_a.x === pos_b.x) {
          if (pos_a.y < pos_b.y) {
            return -1;
          }
          if (pos_a.y > pos_b.y) {
            return 1;
          }
          if (pos_a.y === pos_b.y) {
            return 0;
          }
        }
      });
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
      this.model.on("change:under", this.onChangeUnder);
      this.model.on("change:size", this.onChangeSize);
      this.model.on("change:transform_translation", this.transform);
      this.model.on("change:transform_scale", this.transform);
      this.model.on("change:transform_rotation", this.transform);
      this.model.on("change:transition_translation", this.transform);
      this.model.on("change:transition_scale", this.transform);
      this.collection = this.options.collection;
      return this.$el.appendTo($("#page"));
    };

    BlockView.prototype.events = {
      "tap": "ontap",
      "dragstart": "ondragstart",
      "dragend": "ondragend",
      "drag": "ondrag"
    };

    BlockView.prototype.ontap = function(event) {
      console.log("tap", this.model.get('content').get('title'));
      this.model.set({
        'active': true
      });
      return this.model.set({
        "size": BIG === this.model.get("size") ? SMALL : BIG
      });
    };

    BlockView.prototype.ondragstart = function(event) {
      console.log("ondragstart", event);
      this.model.set({
        'dragging': true
      });
      this.model.set({
        'hover_position': this.model.get("position")
      });
      return this.model.set({
        'placed': false
      });
    };

    BlockView.prototype.ondragend = function(event) {
      console.log("ondragend", event);
      this.model.set({
        'dragging': false
      });
      return this.model.trigger("dropped", this.model);
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
      transition_scale = this.model.get("transition_scale" || "");
      this.$el.children('.inner').css("-webkit-transition", transition_scale);
      this.$el.children('.inner').css("-webkit-transform", css);
      transition_translation = this.model.get("transition_translation" || "");
      this.$el.css("-webkit-transition", transition_translation);
      translation = this.model.get("transform_translation" || "");
      return this.$el.css("-webkit-transform", "translate3d(" + translation + ") ");
    };

    BlockView.prototype.onChangeSize = function() {
      this.model.set({
        "transition_scale": "all 0.1s ease-out 0s"
      });
      return this.setScale();
    };

    BlockView.prototype.onChangeUnder = function() {
      this.model.set({
        "transition_scale": "all 0.5s ease-out 0s"
      });
      return this.setScale();
    };

    BlockView.prototype.setScale = function() {
      var small;
      small = this.model.get("size") === SMALL;
      this.$el.toggleClass("small", small);
      this.$el.children(".inner").css("-webkit-transform-origin", small ? "top left" : "");
      if (this.model.get("under")) {
        this.model.set({
          "transform_scale": small ? 0.4 : 0.8
        });
        return this.$el.children(".inner").css("opacity", 0.5);
      } else {
        this.model.set({
          "transform_scale": small ? 0.5 : null
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
