const Task = require('data.task');
const fs = require('fs');

const compose = (f, g) => (...args) => f(g(...args));
const get = prop => src => src[prop];
const handleErr = e => console.log(`error: ${e}`);
const handleSuccess = x => console.log(`success: ${x}`);

Task.of(1)
  .map(x => x + 1)
  // lazily evaluated
  .fork(handleErr, handleSuccess); // 'success: 2'

Task.rejected('something went wrong!')
  // skips the happy path
  .map(x => x + 1)
  .fork(handleErr, handleSuccess); // 'err: something went wrong!'

const readFileTask = (path) => new Task((reject, resolve) => {
  fs.readFile(path, (err, file) => {
    if (err) {
      return reject(err);
    } 

    return resolve(file);
  });
});

// nothing happens yet
const config = readFileTask('./mock-config.json');
const getPort = compose(get('port'), JSON.parse);
// still nothing happening
const port = config.map(getPort);
// finally `fork` pulls the trigger
port.fork(handleErr, handleSuccess); // 'success: 8000'

// no error yet
const readErr = readFileTask('bad-path').map(getPort);
readErr.fork(handleErr, handleSuccess); // 'error: Error: ENOENT: no such file or directory, open 'bad-path''

// NOTE: port.fork and readErr.fork are not executed synchronously 
// depending on what takes longer, either can finish first
