var Cursor, Logger, Type, Void, childProcess, hook, repeatString, type;

require("isNodeJS");

Void = require("type-utils").Void;

if (isNodeJS) {
  childProcess = require("child_process");
}

repeatString = require("repeat-string");

Logger = require("Logger");

Type = require("Type");

hook = require("hook");

Cursor = require("./Cursor");

type = Type("MainLogger");

type.inherits(Logger);

type.defineValues({
  cursor: function() {
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

type.initInstance(function() {
  var ref, ref1;
  require("temp-log")._ = this;
  this.isColorful = ((ref = this._process) != null ? (ref1 = ref.stdout) != null ? ref1.isTTY : void 0 : void 0) === true;
  return hook.after(this, "_printChunk", function(result, chunk) {
    if (chunk.message === this.ln) {
      return this.cursor._x = 0;
    } else {
      return this.cursor._x += chunk.length;
    }
  });
});

type.defineProperties({
  size: {
    get: function() {
      var ref, ref1;
      if (!((ref = this._process) != null ? (ref1 = ref.stdout) != null ? ref1.isTTY : void 0 : void 0)) {
        return null;
      }
      return this._process.stdout.getWindowSize();
    }
  }
});

type.overrideMethods({
  __willClear: function() {
    if (!isNodeJS) {
      return;
    }
    this.cursor._x = this.cursor._y = 0;
    return this._print(childProcess.execSync("printf '\\33c\\e[3J'", {
      encoding: "utf8"
    }));
  },
  __willClearLine: function(line) {
    var isCurrentLine, message;
    if (!isNodeJS) {
      return;
    }
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

module.exports = type.construct();

//# sourceMappingURL=../../map/src/log.map
