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
    describe 'when i execute flushTimeouts()', ->
      it 'should execute the timeout only once and not register it again to prevent recursion', ->
        interval = ->
          executionCounter++
          setTimeout interval, 0
        setTimeout interval, 0
        flushTimeouts()
        expect(executionCounter).to.equal 1


  describe 'given one timeout which registers a timeout which has an identical callback to an already scheduled', ->
    describe 'when i execute flushTimeouts()', ->
      it 'should not register the timeout with the identical callback again to prevent recursion', ->
        ping = ->
          executionCounter++
          setTimeout pong, 0
        pong = ->
          executionCounter++
          setTimeout ping, 0
        setTimeout ping, 0
        flushTimeouts()
        expect(executionCounter).to.equal 2
