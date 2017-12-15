const through = require('through2');

const toUpperCase = through(function (buffer, encoding, next) {
  this.push(buffer.toString().toUpperCase());
  next();
});

process.stdin.pipe(toUpperCase).pipe(process.stdout);
