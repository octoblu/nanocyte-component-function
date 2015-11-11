Function = require '../../src/function'
Benchmark = require 'simple-benchmark'

describe 'Function', ->
  beforeEach ->
    @start = new Benchmark label: 'benchmark'
    @sut = new Function

  afterEach ->
    @start.prettyPrint()

  describe 'when called with a function', ->
    beforeEach (done) ->
      envelope =
        config:
          func: "return { happy: false, name: 'Aaron'};"
        message: 'smartypants'
      @sut.onEnvelope envelope, (@error, @message) => done()

    it 'should return an error', ->
      expect(@error).to.exist
  describe 'when called with a function with a message', ->
    beforeEach (done) ->
      envelope =
        config:
          func: "return { happy: false, name: msg};"
        message: 'smartypants'
      @sut.onEnvelope envelope, (@error, @message) =>
        done()

    it 'should return an error', ->
      expect(@error).to.exist
  describe 'errors', ->

    describe 'when called with a function with a syntax error', ->
      beforeEach (done) ->
        envelope =
          config:
            func: "qqqq what am I doing? return { happy: false, name: msg};"
          message: 'smartypants'
        @sut.onEnvelope envelope, (@error, @message) => done()

      it 'should return an error', ->
        expect(@error).to.exist

    describe 'when called with a function that throws an error', ->
      beforeEach (done) ->
        envelope =
          config:
            func: "throw new Error('hello, my friend, hello');"
          message: 'smartypants'
        @sut.onEnvelope envelope, (@error, @message) => done()

      it 'should return an error', ->
        expect(@error).to.exist

    describe 'when called with a function that throws a deferred error', ->
      beforeEach (done) ->
        envelope =
          config:
            func: "_.defer(function(){throw new Error('hello, my friend, hello');});"
          message: 'smartypants'
        @child = @sut.onEnvelope envelope, (@error, @message) =>
        @child.on 'exit', done

      it 'should at least kill the child', ->
        expect(@child.connected).to.be.false

    describe 'when called with a function that works forever', ->
      beforeEach (done) ->
        envelope =
          config:
            func: "while(true){}"
          message: 'smartypants'
        @child = @sut.onEnvelope envelope, (@error, @message) =>
        @child.on 'exit', done

      it 'should at least kill the child', ->
        expect(@child.connected).to.be.false

    describe 'when called with a deferred function that throws a deferred error while true', ->
      beforeEach (done) ->
        envelope =
          config:
            func: "_.defer(function(){while(true){_.defer(function(){throw new Error('hello, my friend, hello')})}});"
          message: 'smartypants'
        @child = @sut.onEnvelope envelope, (@error, @message) =>
        @child.on 'exit', done

      it 'should at least kill the child', ->
        expect(@child.connected).to.be.false

    describe 'when called with a function that calls itself in a loop', ->
      beforeEach (done) ->
        envelope =
          config:
            func: """
              function evil() {
                while(true) {
                  evil();
                }
              }
              evil();
            """
          message: 'smartypants'
        @child = @sut.onEnvelope envelope, (@error, @message) =>
        @child.on 'exit', done

      it 'should at least kill the child', ->
        expect(@child.connected).to.be.false

    describe 'when a function tries to use up all the ram in the process', ->
      beforeEach (done) ->
        envelope =
          config:
            func: """
            big = []
            for(var i = 0; i < 10; i++) {
              big.push(Array(255 * 1024 * 1024).join('a'))
            }
            return big
            """
          message: 'smartypants'
        @child = @sut.onEnvelope envelope, (@error, @message) => done()

      it 'should call the callback with an error', ->
        expect(@error).to.exist
