const _ = module.exports;

_.compose = (f, g) => (x) => f(g(x));

_.identity = (x) => x;

_.log = (...xs) => (y) => console.log(...xs, y) || y;

_.timeout = (time) => (cb) => () => setTimeout(cb, time);

