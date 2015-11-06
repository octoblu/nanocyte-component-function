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
      child.kill 'SIGKILL'
      callback null, new Error('Function took too long')
    , 1000

    child.on 'message', (envelope) =>
      @childDone = true
      child.kill 'SIGKILL'
      callback null, envelope.message

module.exports = Function
