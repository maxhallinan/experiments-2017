const fs = require('fs');

const compose = (a, b) => x => a(b(x));
const handleNull = compose(
  e => e.message,
  () => new Error('Error...')
);
const identity = x => x;

const Right = x => ({
  chain : (f) => f(x),
  fold: (f, g) => g(x),
  map: (fn) => Right(fn(x)),
});

const Left = x => ({
  chain: () => Left(x),
  fold: (f, g) => f(x),
  map: fn => Left(x),
});

// Either for null values
const fromNullable = x => x === null ? Left(x) : Right(x);

// Either type for function calls
const tryCatch = fn => {
  let result;

  try {
    result = Right(fn());
  } catch (e) {
    result = Left(e);
  }

  return result;
};

const safeUpperCase = str => 
  fromNullable(str)
    .map(s => s.toUpperCase())
    .fold(handleNull,
          identity);

console.log(safeUpperCase('foo')); // -> 'FOO'
console.log(safeUpperCase(null)); // -> 'Error...'

const getPort = (path, defaultPort) => 
  tryCatch(() => fs.readFileSync(path))
  .chain(c => tryCatch(() => JSON.parse(c)))
  .fold(
    () => 3000,
    c => c.port);

console.log(getPort('mock-config.json', 3000)); // -> 8000
console.log(getPort('moc-config.json', 3000)); // -> 3000
