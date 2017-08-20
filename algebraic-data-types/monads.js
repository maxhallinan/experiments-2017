// chain
const Box = x => ({
  chain: f => f(x),
  inspect: () => `Box(${x})`,
  fold: f => f(x), 
  map: f => Box(f(x)), 
});

// this doesn't really make any sense
// you'd normally just do Box(n).map(n => n + 1);
const addLayer = b => Box(b);
const identity = x => x;

const threeMap = Box(1).map(addLayer).map(addLayer);
console.log(threeMap.fold(identity).fold(identity).fold(identity));

const threeChain = Box(1).chain(addLayer).chain(addLayer); // Box(1)
console.log(threeChain.fold(identity)); // 1

const join = m => m.chain(identity);
const m = Box(Box(Box(1)));
const isAssociative = join(m.map(join)) === join(join(m));
console.log(isAssociative); // true
