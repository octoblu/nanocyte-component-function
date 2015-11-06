vm          = require 'vm'
packageJSON = require '../package.json'

class Function
  onEnvelope: (envelope) =>
    {config,message} = envelope

    _         = @freshLodash()
    moment    = @freshMoment()
    tinycolor = @freshTinycolor()

    message ?= {}
    stringified = JSON.stringify(message).replace(/\\/g, '\\\\').replace(/'/g, "\\\'")
    functionText = "var results = (function(msg){#{config.func}})(JSON.parse('#{stringified}'));"

    context = vm.createContext {_:_, moment:moment, tinycolor:tinycolor}
    vm.runInContext functionText, context, timeout: 100
    return context.results

  voidCache: (substr) =>
    for key,value of require.cache
      continue unless new RegExp(substr).test key
      delete require.cache[key]

  freshLodash: =>
    @voidCache "#{packageJSON.name}/node_modules/lodash/"
    require 'lodash'

  freshMoment: =>
    @voidCache "#{packageJSON.name}/node_modules/moment/"
    require 'moment'

  freshTinycolor: =>
    @voidCache "#{packageJSON.name}/node_modules/tinycolor2/"
    require 'tinycolor2'

module.exports = Function
