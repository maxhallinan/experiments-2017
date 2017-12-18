// export a function that spawns a process from a `cmd` string and an `args` array
// return a single duplex stream joining together the stdin and stdout of
// the spawned process

const spawn = require('child_process').spawn;
const duplexer = require('duplexer2');

module.exports = function (cmd, args) {
  const childProc = spawn(cmd, args);

  return duplexer(childProc.stdin, childProc.stdout);  
};
