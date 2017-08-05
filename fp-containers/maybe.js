function Maybe(x) {
  this.__value = x;
}

Maybe.of = function (x) {
  return new Maybe(x);
};

Maybe.prototype.isNothing = function () {
  return this.__value === null || this.__value === undefined;
}

Maybe.prototype.map = function (fn) {
  return this.isNothing ? Maybe.of(null) : Maybe.of(fn(this.__value));
};

Maybe.of(null).map(str => str.toUpperCase()); // -> no-op. doesn't throw.
