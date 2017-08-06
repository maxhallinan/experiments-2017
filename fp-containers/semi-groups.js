const Sum = x => ({
  x,
  concat: ({ x: y }) => Sum(x + y),
  inspect: () => `Sum(${x})`,
});

const two = Sum(1).concat(Sum(1));
console.log(two); // Sum(2)

const All = x => ({
  x,
  concat: ({ x: y }) => All(x && y),
  inspect: () => `All(${x})`,
});

const t = All(true).concat(All(true));
console.log(t); // All(true)
const f = All(true).concat(All(false));
console.log(f); // All(false)

const First = x => ({
  x,
  concat: () => First(x),
  inspect: () => `First(${x})`,
});

const firstName = First('Judy').concat(First('Jacob')).concat(First('Jones'));
console.log(firstName); // -. First('Judy')
