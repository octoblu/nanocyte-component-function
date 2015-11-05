FunctionWorker = require './function-worker'
worker = new FunctionWorker
process.on 'message', (envelope) =>
  process.send worker.onEnvelope(envelope)
  process.exit 0
