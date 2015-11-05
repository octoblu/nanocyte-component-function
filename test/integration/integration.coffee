Function = require '../../src/function'

f = new Function()
envelope =
  message: 5
  config:
    func: """
      _.defer(function(){
        while(true) {
          _.defer(function(){
            throw new Error("I'm Erik. I like to make Aaron waste his time with stupid nonsense.");
          });
        }
      });
    """
  data: {}

startTime = Date.now()
console.log envelope

f.onEnvelope envelope, (error, message) =>
  console.log "It took #{Date.now() - startTime}ms"
  console.log message
