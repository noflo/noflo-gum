noflo = require 'noflo'

# @runtime noflo-browser

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'initialize camera and/or microphone'
  c.icon = 'video-camera'
  c.inPorts.add 'start',
    datatype: 'bang'
  c.inPorts.add 'stop',
    datatype: 'bang'
  c.inPorts.add 'video',
    datatype: 'boolean'
    control: true
    default: true
  c.inPorts.add 'audio',
    datatype: 'boolean'
    control: true
    default: false
  c.outPorts.add 'stream',
    datatype: 'object'
  c.outPorts.add 'url',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'

  stream = null
  ctx = null
  stopStream = ->
    if stream and stream.stop
      stream.stop()
      stream = null
    if ctx
      ctx.deactivate()
      ctx = null
  c.tearDown = (callback) ->
    do stopStream
    do callback

  c.process (input, output, context) ->
    if input.hasData 'stop'
      input.getData 'stop'
      stopStream()
      output.done()
      return
    return unless input.hasData 'start'
    input.getData 'start'
    # Stop previous stream, if any
    stopStream()

    unless navigator?.mediaDevices
      output.done new Error 'navigator.mediaDevices not available.'
      return
    unless navigator?.mediaDevices.getUserMedia
      # In higher-level graph should provide option to chose image
      # with file picker here. This will make it work on mobile etc.
      output.done new Error 'navigator.mediaDevices.getUserMedia not available.'
      return

    video = if input.hasData('video') then input.getData('video') else true
    audio = if input.hasData('audio') then input.getData('audio') else false

    navigator.mediaDevices.getUserMedia
      video: video
      audio: audio
    .then (mediaStream) ->
      stream = mediaStream
      ctx = context

      # Shim
      unless window.URL?
        window.URL = (
          window.webkitURL ||
          window.msURL ||
          window.oURL ||
          null)
      if window.URL.createObjectURL
        output.send
          url: window.URL.createObjectURL stream
      else
        output.send
          url: stream
      output.send
        stream: stream
    , (err) ->
      output.done err
