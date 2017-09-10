const Task = require('./task');
const { 
  compose, 
  identity, 
  log, 
  timeout,
} = require('./util');

const randomBool = () => Math.ceil(Math.random() * 10) % 2 > 0;

const randomAsync = () => new Task((reject, resolve) =>
  setTimeout(() => randomBool() 
      ? resolve('Hello World') 
      : reject('Err!'), 
    0));

const resolveOrReject = (isFail) => (x) => new Task((reject, resolve) => 
  isFail ? reject(x) : resolve(x));

const fail = resolveOrReject(true);
const succeed = resolveOrReject(false);

const foo = (t) => t
  .ap(Task.of(log('ap')))
  .bimap(log('bimapped left'), log('bimapped right'))
  .chain(compose(Task.of, log('chained')))
  .map(log('mapped'))
  .fork(log('rejected'), log('resolved'));

log('\n----fail----')('')
foo(fail(0));
log('\n----succeed----')('')
foo(succeed(1));
