const Task = require('data.task');

const Left = x => ({
  fold: (f, g) => f(x),
  inspect: x => `Left(${x})`,
  map: f => Left(x),
});

const Right = x => ({
  fold: (f, g) => g(x),
  inspect: x => `Right(${x})`,
  map: f => Right(f(x)),
});

// natural transformations
const eitherToTask = e => e.fold(Task.rejected, Task.of);

// this is not working because Task.prototype.fold returns a Task
// ask about this:
// const taskToEither = t =>
//   t.fold(Left, Right);

const id = x => x;
const toUpperCase = str => str.toUpperCase();
const logErr = err => console.log(`err: ${err}`);
const logRes = res => console.log(res);

// law of natural transformations:
// nt(x).map(f) === nt(x.map(f))
const e1 = eitherToTask(Right('foo'))
  .map(toUpperCase); // Task('FOO')
const e2 = eitherToTask(
  Right('foo').map(toUpperCase)); // Task('FOO')

e1.fork(logErr, logRes); // 'FOO'
e2.fork(logErr, logRes); // 'FOO'
