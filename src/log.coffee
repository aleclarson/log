
require "isNodeJS"

childProcess = require "child_process" if isNodeJS
repeatString = require "repeat-string"
didExit = require "exit"
Logger = require "Logger"
Void = require "Void"
Type = require "Type"
hook = require "hook"

Cursor = require "./Cursor"

type = Type "MainLogger"

type.inherits Logger

type.defineValues

  cursor: ->
    return unless isNodeJS
    return Cursor this

  _process: ->
    return unless isNodeJS
    proc = global.process
    if proc.stdout
      @_print = (message) ->
        proc.stdout.write message
    return proc

if isNodeJS then type.initInstance ->

  @isColorful = @_process.stdout?.isTTY is yes

  @cursor.isHidden = yes
  didExit.once =>
    @cursor.isHidden = no

  hook.after this, "_printChunk", (result, chunk) ->
    if chunk.message is @ln then @cursor._x = 0
    else @cursor._x += chunk.length

type.defineProperties

  size: get: ->
    return null unless isNodeJS and @_process.stdout?.isTTY
    return @_process.stdout.getWindowSize()

if isNodeJS then type.overrideMethods

  __willClear: ->

    @cursor._x = @cursor._y = 0

    @_print childProcess.execSync "printf '\\33c\\e[3J'", encoding: "utf8"

  __willClearLine: (line) ->

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
