do ->
  scheduledTimeouts = []
  currentFlushedTimeout = null
  root = null
  if typeof process isnt 'undefined'
    root = global
  else
    root = window

  root.originalSetTimeout = root.setTimeout

  root.setTimeout = (callback, delay) ->
    timeoutId = root.originalSetTimeout ->
      removeTimeout timeoutId
      callback()
    , delay
    scheduledTimeouts.push
      timeoutId: timeoutId
      callback: callback
      parent: currentFlushedTimeout
    timeoutId


  root.flushTimeouts = (allowedCallStackSize = root.flushTimeouts.allowedCallStackSize) ->
    if scheduledTimeouts.length is 0
      throw new Error 'flushTimeouts: No timeouts scheduled which could be flushed.'
    while (currentFlushedTimeout = scheduledTimeouts.shift())
      clearTimeout currentFlushedTimeout.timeoutId
      if not timeoutWouldResultInRecursion currentFlushedTimeout, allowedCallStackSize
        currentFlushedTimeout.callback()
    currentFlushedTimeout = null


  root.flushTimeouts.allowedCallStackSize = 10

  removeTimeout = (timeoutId) ->
    scheduledTimeouts = scheduledTimeouts.filter (timeout) -> timeout.timeoutId isnt timeoutId


  timeoutWouldResultInRecursion = (timeoutToCheck, allowedCallStackSize) ->
    parentCallbacks = []
    timeout = timeoutToCheck
    while (timeout = timeout.parent)
      parentCallbacks.push timeout.callback
    identicalCallbacks = parentCallbacks.filter (parentCallback) ->
      areCallbacksIdentical timeoutToCheck.callback, parentCallback
    identicalCallbacks.length >= allowedCallStackSize


  areCallbacksIdentical = (callback1, callback2) ->
    if callback1.toString
      return callback1.toString() is callback2.toString()
    else
      return callback1 is callback2