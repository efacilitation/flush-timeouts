# flush-timeout

Override `setTimeout` and provide flushing capabilities.

## API

### global.originalSetTimeout

This method is the original version of `global.setTimeout`.
Use this if you want to register a not flushable timeout.

### global.setTimeout

This method is the decorated version of `global.setTimeout`. 
It schedules the timeout for execution and also saves it in a collection so it can be flushed.

### global.flushTimeouts

This method synchronously executes all pending timeouts in the order they were registered.
If a timeout registers another timeout it will be also executed after the others.
**Note:** This method does not respect the provided delay interval.