const noflo = require('noflo');

// @runtime noflo-browser

exports.getComponent = () => {
  const c = new noflo.Component();
  c.description = 'initialize camera and/or microphone';
  c.icon = 'video-camera';
  c.inPorts.add('start', {
    datatype: 'bang',
  });
  c.inPorts.add('stop', {
    datatype: 'bang',
  });
  c.inPorts.add('video', {
    datatype: 'boolean',
    control: true,
    default: true,
  });
  c.inPorts.add('audio', {
    datatype: 'boolean',
    control: true,
    default: false,
  });
  c.outPorts.add('stream', {
    datatype: 'object',
  });
  c.outPorts.add('url', {
    datatype: 'string',
  });
  c.outPorts.add('error', {
    datatype: 'object',
  });

  let stream = null;
  let ctx = null;
  const stopStream = () => {
    if (stream && stream.stop) {
      stream.stop();
      stream = null;
    }
    if (ctx) {
      ctx.deactivate();
      ctx = null;
    }
  };
  c.tearDown = (callback) => {
    stopStream();
    callback();
  };

  c.process((input, output, context) => {
    if (input.hasData('stop')) {
      input.getData('stop');
      stopStream();
      output.done();
      return;
    }
    if (!input.hasData('start')) { return; }
    input.getData('start');
    // Stop previous stream, if any
    stopStream();

    if (!(typeof navigator !== 'undefined' && navigator !== null ? navigator.mediaDevices : undefined)) {
      output.done(new Error('navigator.mediaDevices not available.'));
      return;
    }
    if (!(typeof navigator !== 'undefined' && navigator !== null ? navigator.mediaDevices.getUserMedia : undefined)) {
      // In higher-level graph should provide option to chose image
      // with file picker here. This will make it work on mobile etc.
      output.done(new Error('navigator.mediaDevices.getUserMedia not available.'));
      return;
    }

    const video = input.hasData('video') ? input.getData('video') : true;
    const audio = input.hasData('audio') ? input.getData('audio') : false;

    navigator.mediaDevices.getUserMedia({
      video,
      audio,
    }).then((mediaStream) => {
      stream = mediaStream;
      ctx = context;

      // Shim
      if (window.URL == null) {
        window.URL = (
          window.webkitURL
          || window.msURL
          || window.oURL
          || null);
      }
      if (window.URL.createObjectURL) {
        output.send({ url: window.URL.createObjectURL(stream) });
      } else {
        output.send({ url: stream });
      }
      return output.send({ stream });
    },
    (err) => output.done(err));
  });

  return c;
};
