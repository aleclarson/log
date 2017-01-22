
isType = require "isType"
Type = require "Type"
sync = require "sync"

log = require "./log"
log.caret = require "./caret"

# Add pretty formatting for 'Type::optionTypes.toString()'
Type.Builder._stringifyTypes = (types) ->
  typeNames = gatherTypeNames types
  log._format typeNames, {unlimited: yes, colors: no}

gatherTypeNames = (type) ->
  if isType type, Object
  then sync.map type, gatherTypeNames
  else if type.getName
  then type.getName()
  else type.name

module.exports = log
