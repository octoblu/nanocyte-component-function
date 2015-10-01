ReturnValue = require 'nanocyte-component-return-value'

class Function extends ReturnValue
  onEnvelope: (envelope) =>
    return envelope.message

module.exports = Function
