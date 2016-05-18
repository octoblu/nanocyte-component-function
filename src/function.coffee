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

    child.on 'message', (message) =>
      return if @childDone

      if message.type == 'error'
        @childDone = true
        child.kill 'SIGKILL'
        callback new Error message.error
        return

      if message.type == 'ready'
        setTimeout =>
          return if @childDone
          @childDone = true
          child.kill 'SIGKILL'
          callback new Error('Function took too long')
        , 1000
        return

      if message.type == 'envelope'
        @childDone = true
        child.kill 'SIGKILL'
        {envelope} = message
        callback null, envelope.message
        return

    return child

module.exports = Function
