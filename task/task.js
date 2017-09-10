const { identity, } = require('./util');

class Task {
  constructor(computation) {
    this._computation = computation;
  }

  static of(x) {
    return new Task((reject, resolve) => resolve(x));
  }

  ap(t) {
    return new Task((reject, resolve) => this._computation(
      reject,
      (x) => t.fork(identity, f => resolve(f(x))),
    ));
  }

  bimap(a, b) {
    return new Task((reject, resolve) => this._computation(
      x => reject(a(x)),
      x => resolve(b(x))
    ));
  }

  chain(f) {
    return new Task((reject, resolve) => this._computation(
      reject,
      (x) => f(x).fork(identity, resolve),
    ));
  }

  map(f) {
    return new Task((reject, resolve) => this._computation(
      // just pass the rejected value on
      reject,
      // compose resolve and the map function f
      (x) => resolve(f(x))
    ));
  }

  fork(failure, success) {
    this._computation(failure, success); 
  }
}

module.exports = Task;

