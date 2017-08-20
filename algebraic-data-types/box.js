const identity = x => x;
const add = x => y => x + y;

// Identity Functor
const Box = x => ({
  fold: f => f(x),
  inspect: () => `Box(${x})`,
  map: fn => Box(fn(x)),
});

const one = Box(1);
const two = one.map(add(1));

console.log(one.fold(identity)); // -> 1
console.log(two.fold(identity)); // -> 2

// moneyToFloat :: String -> Box Number
const moneyToFloat = str =>
  Box(str)
    .map(str => str.replace(/\$/g, ''))
    .map(numStr => parseFloat(numStr));

// moneyToFloat :: String -> Box Number
const percentToFloat = str => 
  Box(str)
    .map(str => str.replace(/\%/g, ''))
    .map(numStr => parseFloat(numStr))
    .map(num => num * 0.01);

// applyDiscount :: String -> String -> Number
const applyDiscount = (price, discount) =>   
  moneyToFloat(price)
  .fold(cost => 
    percentToFloat(discount)
    .fold(savings => cost - cost * savings));

console.log(applyDiscount('$20.00', '20%')); // -> 16

// alternative `Box` implementation

function Container(x) {
  if (this === undefined) {
    return new Container(x);
  }

  this.__value = x;
}

Container.of = function (x) {
  return new Container(x);
}

Container.prototype.map = function (fn) {
  return Container.of(fn(this.__value));
}

Container.prototype.fold = function (fn) {
  return fn(this.__value);
};

console.log(Container.of(1).map(add(1)).fold(identity)); // -> 2

const LazyBox = g => ({
  inspect: () => `LazyBox(${g})`,
  fold: (f) => f(g()),
  map: (f) => LazyBox(() => f(g())),
});

const pureGetEnv = LazyBox(() => process).map(p => p.env);
// nothing impure has happened yet because none of the functions have been called
console.log(pureGetEnv); // LazyBox(() => f(g()))
// finally pull the trigger and call the functions
console.log(pureGetEnv.fold(e => e['EDITOR'])); // 'vim'
