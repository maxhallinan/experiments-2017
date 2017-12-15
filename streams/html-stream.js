// Html input to stdin.
// Convert all inner html to upper-case elements with a class name of "loud".
// Pipe all html to stdout.
const through = require('through2');
const trumpet = require('trumpet');
// Create a new trumpet stream. 
// Both readable and writable.
// Pipe an html stream into `tr` and get back a transformed html stream.
const tr = trumpet();

// Create a new readable writable stream that outputs the content under elem
// and replaces the content with the data written to it.
var loud = tr.select('.loud').createStream();

loud.pipe(through(function (buf, _, next) {
  this.push(buf.toString().toUpperCase());
  next();
  //  Why do i have to pipe it back into `loud`?
  //  https://github.com/nodeschool/discussions/issues/346
})).pipe(loud);

process.stdin.pipe(tr).pipe(process.stdout);
