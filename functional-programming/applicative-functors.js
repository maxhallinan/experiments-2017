const { List, } = require('immutable-ext');

const Box = x => ({
  ap: B2 => B2.map(x),
  inspect: () => `Box(${x})`,
  map: f => Box(f(x)),
});

const res = Box(x => x + 1).ap(Box(2));
// Box(2).map(x => x + 1) === Box((x => x + 1)(2))
console.log(res); // Box(3)

// List comprehension with applicative functors
// imperative example

const xs = ['foo', 'bar', 'baz'];
const ys = ['Foo', 'Bar', 'Baz'];
const zs = ['FOO', 'BAR', 'BAZ'];

const xyzs = [];

const listComp = x => y => z => `${x}-${y}-${z}`;

for (x in xs) {
  for (y in ys) {
    for (z in zs) {
      xyzs.push(listComp(xs[x])(ys[y])(zs[z]))
    }
  }
}

// functional example (using applicative functor List)

const comp = List.of(listComp)
  .ap(List(xs))
  .ap(List(ys))
  .ap(List(zs))
  .foldMap(x => [ x ]);

console.log(xyzs);
console.log(comp);
