describe('GetUserMedia component', () => {
  let c = null;
  let sStart = null;
  let sUrl = null;
  let sError = null;
  let loader = null;
  before(() => {
    loader = new noflo.ComponentLoader(baseDir);
  });
  beforeEach(function (done) {
    this.timeout(4000);
    loader.load('gum/GetUserMedia', (err, instance) => {
      if (err) {
        done(err);
        return;
      }
      c = instance;
      sStart = noflo.internalSocket.createSocket();
      sUrl = noflo.internalSocket.createSocket();
      sError = noflo.internalSocket.createSocket();
      c.inPorts.start.attach(sStart);
      c.outPorts.url.attach(sUrl);
      c.outPorts.error.attach(sError);
      done();
    });
  });

  describe('when instantiated', () => {
    it('should have four input ports', () => {
      chai.expect(c.inPorts.start).to.be.an('object');
      chai.expect(c.inPorts.stop).to.be.an('object');
      chai.expect(c.inPorts.video).to.be.an('object');
      chai.expect(c.inPorts.audio).to.be.an('object');
    });
    it('should have three output ports', () => {
      chai.expect(c.outPorts.stream).to.be.an('object');
      chai.expect(c.outPorts.url).to.be.an('object');
      chai.expect(c.outPorts.error).to.be.an('object');
    });
  });

  describe('when started', () => {
    it('should send an error that gum isn\'t available', () => {
      sError.once('data', (err) => chai.expect(err).to.be.an('error'));
      sStart.send(true);
    });
  });
});
