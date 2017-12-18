const http = require('http');
const through = require('through2');

const toUpperCase = through(function (buffer, _, next) {
  const upper = buffer.toString().toUpperCase();

  this.push(upper);

  next();
});

const server = http.createServer(function (req, res) {
  if (req.method === 'POST') {
    req
    .pipe(toUpperCase)
    .pipe(res);
  }
});
server.listen(process.argv[2]);
