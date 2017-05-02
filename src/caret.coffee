
assertType = require "assertType"
didExit = require "didExit"
Type = require "Type"

log = require "./log"

type = Type "Caret"

type.defineValues ->

  _x: 0

  _hidden: no

  _savedPositions: []

  _restoredPositions: []

  _exitListener: null

  _printListener: log.willPrint (chunk) =>
    if chunk.message is log.ln
    then @_x = 0
    else @_x += chunk.length
    return

#
# Prototype
#

type.defineGetters

  position: -> {@x, @y}

type.definePrototype

  x:
    get: -> @_x
    set: (newValue, oldValue) ->
      assertType newValue, Number
      newValue = Math.max 0, newValue

      if windowSize = process.stdout.getWindowSize()
        newValue = Math.min windowSize[0], newValue

      return if newValue is oldValue

      # Ensure the log is up-to-date before we move the cursor.
      log.flush()

      if newValue > oldValue
      then @_right newValue - oldValue
      else @_left oldValue - newValue

      @_x = newValue
      return

  y:
    get: -> @_y
    set: (newValue, oldValue) ->
      assertType newValue, Number
      newValue = Math.max 0, Math.min log.lines.length, newValue
      return if newValue is oldValue

      # Ensure the log is up-to-date before we move the cursor.
      log.flush()

      if newValue > oldValue
      then @_down newValue - oldValue
      else @_up oldValue - newValue

      @_y = newValue
      return

  isHidden:
    get: -> @_hidden
    set: (newValue, oldValue) ->
      if newValue isnt oldValue
        @_hidden = newValue
        log.ansi "?25" + if newValue then "l" else "h"
        @_exitListener ?= didExit.once => @isHidden = no
      return

  _y:
    get: -> log._line
    set: (newValue) ->
      log._line = newValue
      return

type.defineMethods

  move: ({ x, y }) ->
    @y = y if y?
    @x = x if x?
    return

  save: ->
    @_savedPositions.push @position
    return

  restore: ->
    position = @_savedPositions.pop()
    @_restoredPositions.push position
    @move position
    return

  _up: (n = 1) -> log.ansi "#{n}F"

  _down: (n = 1) -> log.ansi "#{n}E"

  _left: (n = 1) -> log.ansi "#{n}D"

  _right: (n = 1) -> log.ansi "#{n}C"

module.exports = type.construct()
