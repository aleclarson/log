
require "isNodeJS"

repeatString = require "repeat-string"
clampValue = require "clampValue"
Logger = require "Logger"
Type = require "Type"
hook = require "hook"

{stdout} = process
isTTY = isNodeJS and stdout.isTTY

type = Type "MainLogger"

type.inherits Logger

type.defineValues

  _offset: 0

  _print: ->

    if isReactNative and global.nativeLoggingHook
      return (message) ->
        global.nativeLoggingHook message, 1
        console.log message

    if stdout
      return (message) ->
        stdout.write message

    return console.log.bind console

isNodeJS and
type.initInstance ->
  @isColorful = isTTY
  isTTY and hook.after this, "_printChunk", (_, chunk) ->
    if chunk.message is @ln then @_offset = 0
    else @_offset += chunk.length

type.defineGetters

  offset: -> @_offset

  size:
    if isTTY then -> stdout.getWindowSize()
    else -> null

isTTY and
type.defineMethods

  setOffset: (offset) ->
    oldValue = @_offset
    newValue = clampValue offset, 0, @size[0]
    if newValue isnt oldValue
      @_offset = newValue
      @ansi ansi =
        if newValue > oldValue
        then "#{newValue - oldValue}C"
        else "#{oldValue - newValue}D"
    return

  setLine: (line) ->
    oldValue = @_line
    newValue = clampValue line, 0, @lines.length
    if newValue isnt oldValue
      @_line = newValue
      @ansi ansi =
        if newValue > oldValue
        then "#{newValue - oldValue}E"
        else "#{oldValue - newValue}F"
    return

  clearLine: ->
    @setOffset 0
    message = repeatString " ", @line.length
    @_printToChunk message, {line: @_line, hidden: yes}
    @setOffset 0
    return

module.exports = type.construct()
