const identity = x => x;
const handleNull = () => 'Error...';

const Right = x => ({
  fold: (f, g) => g(x),
  map: fn => Right(fn(x)),
});

const Left = x => ({
  fold: (f, g) => f(x),
  map: fn => Left(x),
});

// Either for null values
const fromNullable = x => x === null ? Left(x) : Right(x);

const safeUpperCase = str => 
  fromNullable(str)
    .map(s => s.toUpperCase())
    .fold(handleNull,
          identity);

console.log(safeUpperCase('foo')); // -> 'FOO'
console.log(safeUpperCase(null)); // -> 'Error...'
