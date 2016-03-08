FunctionWorker = require './function-worker'
worker = new FunctionWorker

process.send type: 'ready'

process.on 'message', (envelope) =>
  try
    message = worker.onEnvelope(envelope)
    process.send type: 'envelope', envelope: {message: message}
  catch error
    process.send error: error.message

  process.exit 0
