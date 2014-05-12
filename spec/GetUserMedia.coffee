noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  GetUserMedia = require '../components/GetUserMedia.coffee'
else
  GetUserMedia = require 'noflo-gum/components/GetUserMedia.js'


describe 'GetUserMedia component', ->
  c = null
  s_start = null
  s_url = null
  s_error = null
  beforeEach ->
    c = GetUserMedia.getComponent()
    s_start = noflo.internalSocket.createSocket()
    s_url = noflo.internalSocket.createSocket()
    s_error = noflo.internalSocket.createSocket()
    c.inPorts.start.attach s_start
    c.outPorts.url.attach s_url
    c.outPorts.error.attach s_error

  describe 'when instantiated', ->
    it 'should have four input ports', ->
      chai.expect(c.inPorts.start).to.be.an 'object'
      chai.expect(c.inPorts.stop).to.be.an 'object'
      chai.expect(c.inPorts.video).to.be.an 'object'
      chai.expect(c.inPorts.audio).to.be.an 'object'
    it 'should have three output ports', ->
      chai.expect(c.outPorts.stream).to.be.an 'object'
      chai.expect(c.outPorts.url).to.be.an 'object'
      chai.expect(c.outPorts.error).to.be.an 'object'

  describe 'when started', ->
    if navigator? and (navigator.getUserMedia or navigator.webkitGetUserMedia or navigator.mozGetUserMedia or navigator.msGetUserMedia)
      # Can't be tested without interaction
      it 'should make a url on permission', (done) ->
        @timeout 10000
        s_url.once "data", (url) ->
          chai.expect(url).to.be.a 'string'
          done()
        s_start.send true
    else
      it 'should send an error that gum isn\'t available', ->
        s_error.once "data", (err) ->
          chai.expect(err).to.be.an 'object'
        s_start.send true
