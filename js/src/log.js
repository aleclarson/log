var Cursor, Logger, Type, Void, childProcess, didExit, hook, repeatString, type;

require("isNodeJS");

if (isNodeJS) {
  childProcess = require("child_process");
}

repeatString = require("repeat-string");

didExit = require("exit");

Logger = require("Logger");

Void = require("Void");

Type = require("Type");

hook = require("hook");

Cursor = require("./Cursor");

type = Type("MainLogger");

type.inherits(Logger);

type.defineValues({
  cursor: function() {
    if (!isNodeJS) {
      return;
    }
    return Cursor(this);
  },
  _process: function() {
    var proc;
    if (!isNodeJS) {
      return;
    }
    proc = global.process;
    if (proc.stdout) {
      this._print = function(message) {
        return proc.stdout.write(message);
      };
    }
    return proc;
  }
});

if (isNodeJS) {
  type.initInstance(function() {
    var ref;
    this.isColorful = ((ref = this._process.stdout) != null ? ref.isTTY : void 0) === true;
    this.cursor.isHidden = true;
    didExit.once((function(_this) {
      return function() {
        return _this.cursor.isHidden = false;
      };
    })(this));
    return hook.after(this, "_printChunk", function(result, chunk) {
      if (chunk.message === this.ln) {
        return this.cursor._x = 0;
      } else {
        return this.cursor._x += chunk.length;
      }
    });
  });
}

type.defineProperties({
  size: {
    get: function() {
      var ref;
      if (!(isNodeJS && ((ref = this._process.stdout) != null ? ref.isTTY : void 0))) {
        return null;
      }
      return this._process.stdout.getWindowSize();
    }
  }
});

if (isNodeJS) {
  type.overrideMethods({
    __willClear: function() {
      this.cursor._x = this.cursor._y = 0;
      return this._print(childProcess.execSync("printf '\\33c\\e[3J'", {
        encoding: "utf8"
      }));
    },
    __willClearLine: function(line) {
      var isCurrentLine, message;
      isCurrentLine = line.index === this._line;
      if (isCurrentLine) {
        this.cursor.x = 0;
      } else {
        this.cursor.save();
        this.cursor.move({
          x: 0,
          y: line.index
        });
      }
      message = repeatString(" ", line.length);
      this._printToChunk(message, {
        line: line.index,
        hidden: true
      });
      if (isCurrentLine) {
        return this.cursor.x = 0;
      } else {
        return this.cursor.restore();
      }
    }
  });
}

module.exports = type.construct();

//# sourceMappingURL=../../map/src/log.map
