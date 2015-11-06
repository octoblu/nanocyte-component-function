FunctionWorker = require './function-worker'
worker = new FunctionWorker
process.on 'message', (envelope) =>

  try
    message = worker.onEnvelope(envelope)
    process.send message: message
  catch error
    process.send error: error.stack

  process.exit 0
