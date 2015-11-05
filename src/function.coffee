CallbackComponent = require 'nanocyte-component-callback'
path = require 'path'

class Function extends CallbackComponent
  constructor: (dependencies={}) ->
    {@child_process} = dependencies
    @child_process ?= require 'child_process'

  onEnvelope: (envelope, callback) =>
    child = @child_process.fork path.join( __dirname, './function-worker-runner.js')

    child.send envelope

    setTimeout =>
      return if @childDone
      child.kill 'SIGKILL'
      callback new Error('Function took too long')
    , 1000

    child.on 'message', (message) =>
      @childDone = true
      child.kill 'SIGKILL'
      callback null, message

module.exports = Function
