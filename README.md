# flush-timeout

Override `setTimeout` and provide flushing capabilities.

## API

### global.originalSetTimeout

This method is the original version of `global.setTimeout`.
Use this if you want to register a not flushable timeout.

### global.setTimeout

This method is the decorated version of `global.setTimeout`. 
It schedules the timeout for execution and also saves it in a collection so it can be flushed.

### global.flushTimeouts(allowedCallStackSize)

This method synchronously executes all pending timeouts in the order they were registered.
If a timeout registers another timeout it will be also executed after the others.
**Note:** This method does not respect the provided delay interval.

Timeouts are often used to do asynchronous batch processing and regular background checks.
Flushing timeouts synchronously for these kind of functions could result in infinite recursion.
Therefore flushTimeouts() accepts an optional allowed call stack size to prevent too many recursive calls.
If no value if is given the default allowed call stack size is used which is initially 10.


### global.flushTimeouts.allowedCallStackSize

This property holds the default value for an allowed call stack size used by flushTimeouts().