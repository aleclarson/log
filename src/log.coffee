
isReactNative = require "isReactNative"
repeatString = require "repeat-string"
clampValue = require "clampValue"
isNodeJS = require "isNodeJS"
Logger = require "Logger"
Type = require "Type"

if stdout = process.stdout
  isTTY = stdout.isTTY

type = Type "MainLogger"

type.inherits Logger

type.defineValues

  _print: do ->

    if isReactNative and global.nativeLoggingHook
      return (message) ->
        global.nativeLoggingHook message, 1
        console.log message

    if stdout
      return (message) ->
        stdout.write message

    return console.log.bind console

type.initInstance ->
  @isColorful = isTTY

type.defineGetters

  offset: -> @_offset

isTTY and
type.defineMethods

  updateLine: (contents) ->
    {line} = this
    line.contents = contents
    line.length = contents.length
    @caret.x = line.length
    return

  clearLine: ->
    {line} = this

    # Scrub every printed character.
    @caret.x = 0
    message = repeatString " ", line.length
    @_printToChunk message
    @caret.x = 0

    # Reset the line state.
    line.contents = ""
    line.length = 0
    return

module.exports = type.construct()
