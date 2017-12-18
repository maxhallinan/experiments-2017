const stream = require('stream');
const concat = require('concat-stream');

process.stdin
  .pipe(concat(function (d) {
    const s = d.toString();
    const reversed = s.split('').reverse().join('');

    process.stdout.write(reversed);
  }));
