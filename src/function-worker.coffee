vm          = require 'vm'
packageJSON = require '../package.json'

class Function
  onEnvelope: (envelope) =>
    {config,message,metadata} = envelope

    _         = require 'lodash'
    moment    = require 'moment'
    tinycolor = require 'tinycolor2'
    UUID      = require 'uuid'

    message ?= {}

    functionText = "var results = (function(){\n#{config.func}\n})();"
    dependencies = {
      _
      moment
      tinycolor
      metadata
      UUID
      msg: message
    }
    context = vm.createContext dependencies
    vm.runInContext functionText, context, timeout: 300
    return context.results

module.exports = Function
