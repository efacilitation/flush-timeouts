do ->
  scheduledTimeouts = []
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
    timeoutId


  removeTimeout = (timeoutId) ->
    scheduledTimeouts = scheduledTimeouts.filter (timeout) -> timeout.timeoutId isnt timeoutId


  root.flushTimeouts = ->
    if scheduledTimeouts.length is 0
      throw new Error 'flushTimeouts: No timeouts scheduled which could be flushed.'
    while (timeout = scheduledTimeouts.shift())
      clearTimeout timeout.timeoutId
      timeout.callback()