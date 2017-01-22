var Logger, Type, clampValue, isNodeJS, isReactNative, isTTY, repeatString, stdout, type;

isReactNative = require("isReactNative");

repeatString = require("repeat-string");

clampValue = require("clampValue");

isNodeJS = require("isNodeJS");

Logger = require("Logger");

Type = require("Type");

if (stdout = process.stdout) {
  isTTY = stdout.isTTY;
}

type = Type("MainLogger");

type.inherits(Logger);

type.defineValues({
  _print: function() {
    if (isReactNative && global.nativeLoggingHook) {
      return function(message) {
        global.nativeLoggingHook(message, 1);
        return console.log(message);
      };
    }
    if (stdout) {
      return function(message) {
        return stdout.write(message);
      };
    }
    return console.log.bind(console);
  }
});

type.initInstance(function() {
  return this.isColorful = isTTY;
});

type.defineGetters({
  offset: function() {
    return this._offset;
  }
});

isTTY && type.defineMethods({
  updateLine: function(contents) {
    var line;
    line = this.line;
    line.contents = contents;
    line.length = contents.length;
    this.caret.x = line.length;
  },
  clearLine: function() {
    var line, message;
    line = this.line;
    this.caret.x = 0;
    message = repeatString(" ", line.length);
    this._printToChunk(message);
    this.caret.x = 0;
    line.contents = "";
    line.length = 0;
  }
});

module.exports = type.construct();

//# sourceMappingURL=map/log.map
