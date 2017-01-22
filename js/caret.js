var Type, assertType, didExit, log, type;

assertType = require("assertType");

didExit = require("didExit");

Type = require("Type");

log = require("./log");

type = Type("Caret");

type.defineValues(function() {
  return {
    _x: 0,
    _hidden: false,
    _savedPositions: [],
    _restoredPositions: []
  };
});

type.defineFrozenValues({
  _printListener: function() {
    return log.willPrint((function(_this) {
      return function(chunk) {
        if (chunk.message === log.ln) {
          return _this._x = 0;
        } else {
          return _this._x += chunk.length;
        }
      };
    })(this)).start();
  }
});

type.initInstance(function() {
  this.isHidden = true;
  return didExit(1, (function(_this) {
    return function() {
      return _this.isHidden = false;
    };
  })(this)).start();
});

type.defineGetters({
  position: function() {
    return {
      x: this.x,
      y: this.y
    };
  }
});

type.definePrototype({
  x: {
    get: function() {
      return this._x;
    },
    set: function(newValue, oldValue) {
      var windowSize;
      assertType(newValue, Number);
      newValue = Math.max(0, newValue);
      if (windowSize = process.stdout.getWindowSize()) {
        newValue = Math.min(windowSize[0], newValue);
      }
      if (newValue === oldValue) {
        return;
      }
      log.flush();
      if (newValue > oldValue) {
        this._right(newValue - oldValue);
      } else {
        this._left(oldValue - newValue);
      }
      this._x = newValue;
    }
  },
  y: {
    get: function() {
      return this._y;
    },
    set: function(newValue, oldValue) {
      assertType(newValue, Number);
      newValue = Math.max(0, Math.min(log.lines.length, newValue));
      if (newValue === oldValue) {
        return;
      }
      log.flush();
      if (newValue > oldValue) {
        this._down(newValue - oldValue);
      } else {
        this._up(oldValue - newValue);
      }
      this._y = newValue;
    }
  },
  isHidden: {
    get: function() {
      return this._hidden;
    },
    set: function(newValue, oldValue) {
      if (newValue !== oldValue) {
        this._hidden = newValue;
        log.ansi("?25" + (newValue ? "l" : "h"));
      }
    }
  },
  _y: {
    get: function() {
      return log._line;
    },
    set: function(newValue) {
      log._line = newValue;
    }
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
    return log.ansi(n + "F");
  },
  _down: function(n) {
    if (n == null) {
      n = 1;
    }
    return log.ansi(n + "E");
  },
  _left: function(n) {
    if (n == null) {
      n = 1;
    }
    return log.ansi(n + "D");
  },
  _right: function(n) {
    if (n == null) {
      n = 1;
    }
    return log.ansi(n + "C");
  }
});

module.exports = type.construct();

//# sourceMappingURL=map/caret.map
