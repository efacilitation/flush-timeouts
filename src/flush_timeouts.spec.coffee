describe 'flushTimeouts', ->
  executionCounter = null
  incrementExecutionCounter = null
  beforeEach ->
    executionCounter = 0
    incrementExecutionCounter = -> executionCounter++

  describe 'given a scheduled timeout via originalSetTimeout()', ->
    describe 'when i execute flushTimeout()', ->
      it 'should not execute the timeout', ->
        originalSetTimeout incrementExecutionCounter, 0
        try
          flushTimeouts()
        expect(executionCounter).to.equal 0

      it 'should throw an error', ->
        originalSetTimeout incrementExecutionCounter, 0
        expect(-> flushTimeouts()).to.throw Error


    describe 'when the thread is free for execution', ->
      it 'should execute the timeout', (done) ->
        wasExecuted = false
        originalSetTimeout ->
          wasExecuted = true
        , 0
        originalSetTimeout ->
          expect(wasExecuted).to.be.true
          done()
        , 100


  describe 'given no scheduled timeouts', ->
    describe 'when i execute flushTimeouts()', ->
      it 'should throw an error', ->
        expect(-> flushTimeouts()).to.throw Error


  describe 'given one past timeout which was already executed by the system', ->
    describe 'when i execute flushTimeouts()', ->
      it 'should not execute the timeout again', ->
        setTimeout ->
          incrementExecutionCounter()
          done()
        , 0
        try
          flushTimeouts()
        expect(executionCounter).to.equal 1


      it 'should throw an error', ->
        setTimeout ->
          incrementExecutionCounter()
          done()
        , 0
        expect(-> flushTimeouts()).to.throw Error


  describe 'given one timeout which was not yet executed', ->
    describe 'when i execute flushTimeouts()', ->
      it 'should execute the timeout synchronously', ->
        setTimeout incrementExecutionCounter, 0
        flushTimeouts()
        expect(executionCounter).to.equal 1


      it 'should not execute the timeout again by the system', (done) ->
        setTimeout incrementExecutionCounter, 0
        flushTimeouts()
        originalSetTimeout ->
          expect(executionCounter).to.equal 1
          done()
        , 100


    describe 'when i execute flushTimeouts() twice', ->
      it 'should execute the timeout only once', ->
        setTimeout incrementExecutionCounter, 0
        flushTimeouts()
        try
          flushTimeouts()
        expect(executionCounter).to.equal 1


      it 'should throw an error on the second call', ->
        setTimeout incrementExecutionCounter, 0
        flushTimeouts()
        expect(-> flushTimeouts()).to.throw Error


  describe 'given two timeouts which were not yet executed', ->
    describe 'when i execute flushTimeouts()', ->
      it 'should execute both timeouts in order of registration', ->
        message = ''
        setTimeout ->
          message += 'Hello '
        , 0
        setTimeout ->
          message += 'World'
        , 0
        flushTimeouts()
        expect(message).to.equal 'Hello World'


  describe 'given one timeout which registers another timeout', ->
    describe 'when i execute flushTimeouts()', ->
      it 'should execute both timeouts in order of registration', ->
        message = ''
        setTimeout ->
          message += 'Hello '
          setTimeout ->
            message += 'World'
          , 0
        , 0
        flushTimeouts()
        expect(message).to.equal 'Hello World'


  describe 'given one timeout which registers itself as a timeout again (interval emulation)', ->
    describe 'when i execute flushTimeouts() with a default allowed call stack size', ->
      it 'should execute the timeout ten times', ->
        interval = ->
          executionCounter++
          setTimeout interval, 0
        setTimeout interval, 0
        flushTimeouts()
        expect(executionCounter).to.equal 10


    describe 'when i execute flushTimeouts() passing in an allowed call stack size of 1', ->
      it 'should execute the timeout only once', ->
        interval = ->
          executionCounter++
          setTimeout interval, 0
        setTimeout interval, 0
        flushTimeouts 1
        expect(executionCounter).to.equal 1


      it 'should use the default allowed call stack size on consecutive calls', ->
        interval = ->
          executionCounter++
          setTimeout interval, 0
        setTimeout interval, 0
        flushTimeouts 1
        setTimeout interval, 0
        flushTimeouts()
        expect(executionCounter).to.equal 



    describe 'when i change the global allowed stack size to 1 and execute flushTimeouts() multiple times', ->
      it 'should always use the globally configured allowed call stack size', ->
        defaultAllowedCallStackSize = flushTimeouts.allowedCallStackSize
        flushTimeouts.allowedCallStackSize = 1
        interval = ->
          executionCounter++
          setTimeout interval, 0
        setTimeout interval, 0
        flushTimeouts()
        setTimeout interval, 0
        flushTimeouts()
        expect(executionCounter).to.equal 2
        flushTimeouts.allowedCallStackSize = defaultAllowedCallStackSize



  describe 'given one timeout which registers another timeout which then register the first timeout again', ->
    describe 'when i execute flushTimeouts() with an allowed call stack size of 10', ->
      it 'should execute the first and the second timeout each only ten times', ->
        pingCounter = 0
        ping = ->
          pingCounter++
          setTimeout pong, 0
        pongCounter = 0
        pong = ->
          pongCounter++
          setTimeout ping, 0
        setTimeout ping, 0
        flushTimeouts 10
        expect(pingCounter).to.equal 10
        expect(pongCounter).to.equal 10


  describe 'given two timeouts which register each other again as timeouts', ->
    describe 'when i execute flushTimeouts() with an allowed call stack size of 10', ->
      it 'should execute the first and the second timeout each ten times in each run', ->
        pingCounter = 0
        ping = ->
          pingCounter++
          setTimeout pong, 0
        pongCounter = 0
        pong = ->
          pongCounter++
          setTimeout ping, 0
        setTimeout ping, 0
        setTimeout pong, 0
        flushTimeouts 10
        expect(pingCounter).to.equal 20
        expect(pongCounter).to.equal 20
