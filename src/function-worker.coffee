vm          = require 'vm'
packageJSON = require '../package.json'

class Function
  onEnvelope: (envelope) =>
    {config,message,metadata} = envelope

    _         = require 'lodash'
    moment    = require 'moment'
    tinycolor = require 'tinycolor2'

    message ?= {}
    functionText = "var results = (function(){\n#{config.func}\n})();"
    context = vm.createContext {_:_, moment:moment, tinycolor:tinycolor, msg: message, metadata: metadata}
    vm.runInContext functionText, context, timeout: 300
    return context.results

module.exports = Function
