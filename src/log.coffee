
require "isNodeJS"

childProcess = require "child_process" if isNodeJS
repeatString = require "repeat-string"
didExit = require "didExit"
Logger = require "Logger"
Void = require "Void"
Type = require "Type"
hook = require "hook"

Cursor = require "./Cursor"

isTTY = isNodeJS and (process.stdout?.isTTY is yes)

type = Type "MainLogger"

type.inherits Logger

type.defineFrozenValues

  cursor: isTTY and -> Cursor this

  _process: ->

    if isReactNative and global.nativeLoggingHook
      @_print = (message) ->
        global.nativeLoggingHook message, 1
        console.log message
      return null

    if not isNodeJS
      @_print = (message) ->
        console.log message
      return null

    if process.stdout
      @_print = (message) ->
        process.stdout.write message

    return process

isNodeJS and
type.initInstance ->

  @isColorful = isTTY
  return unless isTTY

  hook.after this, "_printChunk", (result, chunk) ->
    if chunk.message is @ln then @cursor._x = 0
    else @cursor._x += chunk.length

  @cursor.isHidden = yes
  onExit = => @cursor.isHidden = no
  onExit = didExit 1, onExit
  onExit.start()

type.defineGetters

  size: ->
    return null if not isTTY
    return @_process.stdout.getWindowSize()

isTTY and
type.overrideMethods

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
