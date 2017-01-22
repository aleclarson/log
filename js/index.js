var Type, gatherTypeNames, isType, log, sync;

isType = require("isType");

Type = require("Type");

sync = require("sync");

log = require("./log");

log.caret = require("./caret");

Type.Builder._stringifyTypes = function(types) {
  var typeNames;
  typeNames = gatherTypeNames(types);
  return log._format(typeNames, {
    unlimited: true,
    colors: false
  });
};

gatherTypeNames = function(type) {
  if (isType(type, Object)) {
    return sync.map(type, gatherTypeNames);
  } else if (type.getName) {
    return type.getName();
  } else {
    return type.name;
  }
};

module.exports = log;

//# sourceMappingURL=map/index.map
