timeouts = []

originalSetTimeout = window.setTimeout

window.setTimeout = (callback, delay) ->
  timeoutId = originalSetTimeout.call window, ->
    callback()
    delete timeout[timeoutId]
  , delay
  timeouts[timeoutId] = callback
  timeoutId

window.flushTimeouts = ->
  timeouts
    .filter (callback) -> callback isnt null 
    .forEach (callback, timeoutId) ->
      if callback
        clearTimeout timeoutId
        callback();


