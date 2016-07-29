
Type = require "Type"
sync = require "sync"

type = Type "Logger_Cursor"

type.defineProperties

  x:
    get: -> @_x
    set: (newValue, oldValue) ->
      newValue = Math.max 0, Math.min @_log.size[0], newValue
      return if newValue is oldValue
      if newValue > oldValue then @_right newValue - oldValue
      else @_left oldValue - newValue
      @_x = newValue

  y:
    get: -> @_y
    set: (newValue, oldValue) ->
      newValue = Math.max 0, Math.min @_log.lines.length, newValue
      return if newValue is oldValue
      if newValue > oldValue then @_down newValue - oldValue
      else @_up oldValue - newValue
      @_y = newValue

  isHidden:
    value: yes
    didSet: (newValue, oldValue) ->
      return if newValue is oldValue
      @_log.ansi "?25" + if newValue then "l" else "h"

  _y:
    get: -> @_log._line
    set: (newValue) -> @_log._line = newValue

type.defineValues

  _log: (logger) -> logger

  _x: 0

  _savedPositions: -> []

  _restoredPositions: -> []

type.defineGetters

  position: -> { @x, @y }

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

  _up: (n = 1) -> @_log.ansi "#{n}F"

  _down: (n = 1) -> @_log.ansi "#{n}E"

  _left: (n = 1) -> @_log.ansi "#{n}D"

  _right: (n = 1) -> @_log.ansi "#{n}C"

module.exports = type.build()
