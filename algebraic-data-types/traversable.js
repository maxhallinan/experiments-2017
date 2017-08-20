const Task = require('data.task');
const fs = require('fs');
// turns a callback-style function into a future
const { futurize } = require('futurize');
const { List, Map, } = require('immutable-ext');

const future = futurize(Task);
const readFile = future(fs.readFile);

// return a fake database entity after a delay of 100ms
const Db = ({
  find: (id) =>
    new Task((rej, res) =>
      setTimeout(() => res({ id, title: `Project ${id}`}), 100)),
});

const reportHeader = (p1, p2) =>
  `Report: ${p1.title} compared to ${p2.title}`;

const logErr = err => console.log(err);
const logRes = res => console.log(res);

Db.find(1)
  .chain(p1 => 
    Db.find(2).map(p2 => 
      reportHeader(p1, p2)))
    .fork(logErr, logRes);

// flatten out the previous example by using applicative functors
Task.of(p1 => p2 => reportHeader(p1, p2))
  .ap(Db.find(3))
  .ap(Db.find(4))
  .fork(logErr, logRes);

const paths = List([ 'mock-config.json', 'mock-config-2.json', ]);
const files = paths.traverse(Task.of, path => readFile(path, 'utf-8'))
  .fork(logErr, logRes);

const httpGet = (path, params) =>
  Task.of(`${path}: result`);

const routes = {
  index: `/`,
  foo: `/foo`,
  fooBar: `/foo/bar`,
};

// Map.map preserves the key names and updates the values
// the result here is `Map { k: path } -> { k: Task res }`
const results = Map(routes).map(route => httpGet(route, {}));

// improve this by using traverse
const results2 = Map(routes)
  .traverse(Task.of, route => httpGet(route, {}))
  .fork(logErr, logRes);

