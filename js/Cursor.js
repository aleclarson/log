var Type, sync, type;

Type = require("Type");

sync = require("sync");

type = Type("Logger_Cursor");

type.defineProperties({
  x: {
    get: function() {
      return this._x;
    },
    set: function(newValue, oldValue) {
      newValue = Math.max(0, Math.min(this._log.size[0], newValue));
      if (newValue === oldValue) {
        return;
      }
      if (newValue > oldValue) {
        this._right(newValue - oldValue);
      } else {
        this._left(oldValue - newValue);
      }
      return this._x = newValue;
    }
  },
  y: {
    get: function() {
      return this._y;
    },
    set: function(newValue, oldValue) {
      newValue = Math.max(0, Math.min(this._log.lines.length, newValue));
      if (newValue === oldValue) {
        return;
      }
      if (newValue > oldValue) {
        this._down(newValue - oldValue);
      } else {
        this._up(oldValue - newValue);
      }
      return this._y = newValue;
    }
  },
  isHidden: {
    value: true,
    didSet: function(newValue, oldValue) {
      if (newValue === oldValue) {
        return;
      }
      return this._log.ansi("?25" + (newValue ? "l" : "h"));
    }
  },
  _y: {
    get: function() {
      return this._log._line;
    },
    set: function(newValue) {
      return this._log._line = newValue;
    }
  }
});

type.defineValues({
  _log: function(logger) {
    return logger;
  },
  _x: 0,
  _savedPositions: function() {
    return [];
  },
  _restoredPositions: function() {
    return [];
  }
});

type.defineGetters({
  position: function() {
    return {
      x: this.x,
      y: this.y
    };
  }
});

type.defineMethods({
  move: function(arg) {
    var x, y;
    x = arg.x, y = arg.y;
    if (y != null) {
      this.y = y;
    }
    if (x != null) {
      this.x = x;
    }
  },
  save: function() {
    this._savedPositions.push(this.position);
  },
  restore: function() {
    var position;
    position = this._savedPositions.pop();
    this._restoredPositions.push(position);
    this.move(position);
  },
  _up: function(n) {
    if (n == null) {
      n = 1;
    }
    return this._log.ansi(n + "F");
  },
  _down: function(n) {
    if (n == null) {
      n = 1;
    }
    return this._log.ansi(n + "E");
  },
  _left: function(n) {
    if (n == null) {
      n = 1;
    }
    return this._log.ansi(n + "D");
  },
  _right: function(n) {
    if (n == null) {
      n = 1;
    }
    return this._log.ansi(n + "C");
  }
});

module.exports = type.build();

//# sourceMappingURL=map/Cursor.map