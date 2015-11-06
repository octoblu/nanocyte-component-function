child_process = require 'child_process'
CallbackComponent = require 'nanocyte-component-callback'
Function = require '../src/function'

describe 'Function', ->
  beforeEach ->
    @envelope = thanks: "ERIK"
    @childObject =
      on: sinon.stub()
      send: sinon.spy()
      kill: sinon.spy()

    @child_process =
      fork: sinon.stub().returns @childObject

    @sut = new Function {}, child_process: @child_process

  it 'should exist', ->
    expect(@sut).to.be.an.instanceOf CallbackComponent

  describe '->onEnvelope', ->
    describe 'when given an envelope from the engine', ->
      beforeEach ->
        @sut.onEnvelope @envelope, =>

      it "should send the envelope it received to the child", ->
        expect(@childObject.send).to.have.been.calledWith @envelope

    describe 'when the child responds with a new message', ->
      beforeEach (done) ->
        @childMessage =
          message:
            youAre: 'WELCOME'

        @sut.onEnvelope @envelope, (@error, @message) => done()

        @childObject.on.yield @childMessage

      it 'should call the callback with that message', ->
        expect(@message).to.deep.equal @childMessage.message

      it 'should violently kill all the children', ->
        expect(@childObject.kill).to.have.been.calledWith 'SIGKILL'

    describe 'when the child process takes longer than 100ms', ->
      beforeEach (done) ->
        @sut.onEnvelope @envelope, (@error, @message) => done()

      it 'should call the callback with error', ->
        expect(@error).to.be.an.instanceof Error

      it 'should violently kill all the children', ->
        expect(@childObject.kill).to.have.been.calledWith 'SIGKILL'

      # it 'should call the callback with an error'
