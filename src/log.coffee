
require "isNodeJS"

{ Void } = require "type-utils"

childProcess = require "child_process" if isNodeJS
repeatString = require "repeat-string"
Logger = require "Logger"
Type = require "Type"
hook = require "hook"

Cursor = require "./Cursor"

type = Type "MainLogger"

type.inherits Logger

type.defineValues

  cursor: -> Cursor this

  _process: ->
    return unless isNodeJS
    proc = global.process
    if proc.stdout
      @_print = (message) ->
        proc.stdout.write message
    return proc

type.initInstance ->

  @isColorful = @_process?.stdout?.isTTY is yes

  hook.after this, "_printChunk", (result, chunk) ->
    if chunk.message is @ln then @cursor._x = 0
    else @cursor._x += chunk.length

type.defineProperties

  size: get: ->
    return null unless @_process?.stdout?.isTTY
    @_process.stdout.getWindowSize()

type.overrideMethods

  __willClear: ->

    return unless isNodeJS

    @cursor._x = @cursor._y = 0

    @_print childProcess.execSync "printf '\\33c\\e[3J'", encoding: "utf8"

  __willClearLine: (line) ->

    return unless isNodeJS

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
