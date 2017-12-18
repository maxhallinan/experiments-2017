// even-numbered lines to upper-case
// odd-numbered lines to lower-case

const split = require('split');
const through = require('through2');

process.stdin
.pipe(split())
.pipe(format())
.pipe(process.stdout)


function format() {
  var lnNum = 1;

  return through(function (line, _, next) {
    let formatted = line.toString();

    if (lnNum % 2 === 0) { 
      formatted = formatted.toUpperCase();
    } else {
      formatted = formatted.toLowerCase();
    }

    this.push(formatted + `\n`);

    lnNum++;

    next();
  });
}
