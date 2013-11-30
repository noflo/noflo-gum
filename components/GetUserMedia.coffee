noflo = require 'noflo'

class GetUserMedia extends noflo.Component
  constructor: ->
    @inPorts =
      in: new noflo.Port
    @outPorts =
      out: new noflo.Port

exports.getComponent = -> new GetUserMedia
