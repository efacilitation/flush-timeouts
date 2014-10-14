do ->
  scheduledTimeouts = []
  currentTimeoutBeingFlushed = null
  root = null
  if typeof process isnt 'undefined'
    root = global
  else
    root = window

  root.originalSetTimeout = root.setTimeout

  root.setTimeout = (callback, delay) ->
    if timeoutWouldResultInRecursion callback
      return
    timeoutId = root.originalSetTimeout ->
      removeTimeout timeoutId
      callback()
    , delay
    scheduledTimeouts.push
      timeoutId: timeoutId
      callback: callback
      parent: currentTimeoutBeingFlushed
    timeoutId


  root.flushTimeouts = ->
    if scheduledTimeouts.length is 0
      throw new Error 'flushTimeouts: No timeouts scheduled which could be flushed.'
    while (currentTimeoutBeingFlushed = scheduledTimeouts.shift())
      clearTimeout currentTimeoutBeingFlushed.timeoutId
      currentTimeoutBeingFlushed.callback()
    currentTimeoutBeingFlushed = null

  removeTimeout = (timeoutId) ->
    scheduledTimeouts = scheduledTimeouts.filter (timeout) -> timeout.timeoutId isnt timeoutId


  timeoutWouldResultInRecursion = (callback) ->
    if currentTimeoutBeingFlushed is null
      return false
    timeout = currentTimeoutBeingFlushed
    callbacksToCheck = [timeout.callback]
    while (timeout = timeout.parent)
      callbacksToCheck.push timeout.callback
    callbacksToCheck.some (callbackToCheck) ->
      areCallbacksIdentical callback, callbackToCheck


  areCallbacksIdentical = (callback1, callback2) ->
    if callback1.toString
      return callback1.toString() is callback2.toString()
    else
      return callback1 is callback2