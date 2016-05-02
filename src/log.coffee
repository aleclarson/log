
require "isNodeJS"

childProcess = require "child_process" if isNodeJS
Logger = require "Logger"
Type = require "Type"
hook = require "hook"

Cursor = require "./Cursor"

type = Type "MainLogger"

type.inherits Logger

type.optionDefaults =
  process: global.process if isNodeJS

type.defineValues

  cursor: -> Cursor this

type.initInstance ->

  require("temp-log")._ = this

  hook.after this, "_printChunk", (result, chunk) ->
    if chunk.message is @ln then @cursor._x = 0
    else @cursor._x += chunk.length

type.overrideMethods

  __willClear: ->

    return unless isNodeJS and @process

    @cursor._x = @cursor._y = 0

    @_print childProcess.execSync "printf '\\33c\\e[3J'", encoding: "utf8"

  __willClearLine: (line) ->

    return unless isNodeJS and @process

    isCurrentLine = line.index is @_line

    if isCurrentLine
      @cursor.x = 0

    else
      @cursor.save()
      @cursor.move x: 0, y: line.index

    message = repeatString " ", line.length
    @_printToChunk message, { line: line.index, hidden: yes }

    if isCurrentLine
      @cursor.x = 0

    else
      @cursor.restore()

module.exports = type.construct()
