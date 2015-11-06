CallbackComponent = require 'nanocyte-component-callback'
path = require 'path'

class Function extends CallbackComponent
  constructor: (options, dependencies={}) ->
    {@child_process} = dependencies
    @child_process ?= require 'child_process'
    super

  onEnvelope: (envelope, callback) =>
    child = @child_process.fork path.join( __dirname, './function-worker-runner.js')

    child.send envelope

    setTimeout =>
      return if @childDone
      @childDone = true
      child.kill 'SIGKILL'
      callback new Error('Function took too long'), null
    , 500

    child.on 'message', (envelope) =>
      return if @childDone
      @childDone = true
      child.kill 'SIGKILL'
      error = new Error(envelope.error) if envelope?.error?
      callback error, envelope.message

module.exports = Function
