do ->
  scheduledTimeouts = []
  lastFlushedTimeouts = []
  isFlushingOngoing = false
  root = null
  if typeof process isnt 'undefined'
    root = global
  else
    root = window

  root.originalSetTimeout = root.setTimeout

  root.setTimeout = (callback, delay) ->
    if isFlushingOngoing and isCallbackAlreadyScheduled callback
      return
    timeoutId = root.originalSetTimeout ->
      removeTimeout timeoutId
      callback()
    , delay
    scheduledTimeouts.push
      timeoutId: timeoutId
      callback: callback
    timeoutId


  root.flushTimeouts = ->
    if scheduledTimeouts.length is 0
      throw new Error 'flushTimeouts: No timeouts scheduled which could be flushed.'
    isFlushingOngoing = true
    lastFlushedTimeouts = []
    while (timeout = scheduledTimeouts.shift())
      lastFlushedTimeouts.push timeout
      clearTimeout timeout.timeoutId
      timeout.callback()
    isFlushingOngoing = false


  removeTimeout = (timeoutId) ->
    scheduledTimeouts = scheduledTimeouts.filter (timeout) -> timeout.timeoutId isnt timeoutId


  isCallbackAlreadyScheduled = (callback) ->
    callbacksToCheck = scheduledTimeouts.map (timeout) -> timeout.callback
    callbacksToCheck = callbacksToCheck.concat lastFlushedTimeouts.map (timeout) -> timeout.callback
    callbacksToCheck.some (callbackToCheck) ->
      areCallbacksIdentical callback, callbackToCheck


  areCallbacksIdentical = (callback1, callback2) ->
    if callback1.toString
      return callback1.toString() is callback2.toString()
    else
      return callback1 is callback2