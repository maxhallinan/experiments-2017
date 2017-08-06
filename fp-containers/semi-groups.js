const Sum = x => ({
  x,
  concat: ({ x: y }) => Sum(x + y),
  inspect: () => `Sum(${x})`,
});

const two = Sum(1).concat(Sum(1));
console.log(two); // Sum(2)

// `empty` makes `Sum` a monoid
Sum.empty = () => Sum(0);
console.log(Sum.empty().concat(two)); // Sum(2)

const All = x => ({
  x,
  concat: ({ x: y }) => All(x && y),
  inspect: () => `All(${x})`,
});

// make `All` a Monoid
All.empty = () => All(true);

const t = All(true).concat(All(true));
console.log(t); // All(true)
const f = All(true).concat(All(false));
console.log(f); // All(false)

console.log(All.empty().concat(t)); // All(true)
console.log(All.empty().concat(f)); // All(false)

const First = x => ({
  x,
  concat: () => First(x),
  inspect: () => `First(${x})`,
});

const firstName = First('Judy').concat(First('Jacob')).concat(First('Jones'));
console.log(firstName); // -. First('Judy')

// Monoids
const Sum = x => ({
  x,
  concat: ({ x: y }) => Sum(x + y),
});
// x + 0 = x
Sum.empty = () => Sum(0)

const Product = x => ({
  x,
  concat: ({ x: y }) => Product(x * y),
});
// x * 1 = x
Product.empty = () => Product(1);

const All = x => ({
  x,
  concat: ({ x: y }) => x && y,
});
// x && true === x
// true && true === true 
// false && true === false 
All.empty = () => All(true);

const Max = x => ({
  x,
  concat: ({ x: y, }) => Max(x > y ? x : y),
});
Max.empty = () => Max(-Infinity);

const Min = x => ({
  x,
  concat: ({ x: y }) => Min(x > y ? y : x),
});
Min.empty = () => Min(Infinity);
