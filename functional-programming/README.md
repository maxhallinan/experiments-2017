# fp-containers

Functional programming with composable container types.


## `Box`

[./box.js](./box.js)

- Box can also be called Container or the Identity functor.
- Box is a Functor.
    - A Functor is a type that implements `map` and obeys some laws.
    - Functor could also be called Mappable.
- Enables composing transformations of that value without storing intermediate values.


### Links

*Articles*

- [Prof. Frisby, Chapter 8: The Mighty Container](https://drboolean.gitbooks.io/mostly-adequate-guide/content/ch8.html#the-mighty-container)

*Tutorials*

- [Brian Lonsdorf, Egghead.io: Create linear data flow with container types (Box)](https://egghead.io/lessons/javascript-linear-data-flow-with-container-style-types-box)
- [Brain Lonsdorf, Egghead.io: Refactoring imperative code to single compose expression using Box](https://egghead.io/lessons/javascript-refactoring-imperative-code-to-a-single-composed-expression-using-box)


## `Maybe`

[./maybe.js](./maybe.js)

- A container type that handles possible `null` value.


## `Either`

[./either.js](./either.js)

- `Either` is a type that returns one of two subtypes: `Right` or `Left`.
- `Either` tests `x`. If the test succeeds, it returns `Right x` and if it fails, 
  it returns `Left x`.
- `Right` and `Left` have the same methods but these methods behave differently.
- `Right.map` and `Left.map` both take `fn`, but `Left.map` will not call `fn`.
- `Right.fold` and `Left.fold` both take `f, g`. `Right.fold` calls `g(x)` and
  `Left.fold` calls `f(x)`.
- This interface allows things like handling unexpected or invalid values without
  risking throwing an error.


### Links

*Articles*

- [Prof. Frisby, Chapter 8: Schroedinger's Maybe](https://drboolean.gitbooks.io/mostly-adequate-guide/content/ch8.html#schrödingers-maybe)

*Tutorials*

- [Brian Lonsdorf, Egghead.io: Enforce a null check with composable code branching with Either](https://egghead.io/lessons/javascript-composable-code-branching-with-either)
- [Brain Lonsdorf, Egghead.io: Use chain for composable error handling with Either](https://egghead.io/lessons/javascript-composable-error-handling-with-either)


## Semi-groups

[./semi-groups.js](./semi-groups.js)

- Semi-groups are used for combining things.
- A Semi-group is a type with a `concat` method.
  - `String` and `Array` are both semi-groups
- `concat` is associative: the result of the combination is the same no matter
  how the operation is grouped.
  - ex: 1 + (1 + 1) = (1 + 1) + 1 = 1 + 1 + 1


### Monoids

- A semi-group that contains a special neutral element acting like `identity`.
- A semi-group type has a method like `empty` that returns that neutral element.
- The value of the neutral element is that it provides a baseline for safe operation.


### Links

*Tutorials*

- [Brian Lonsdorf, Egghead.io: Ensure failsafe combination with monoids](https://egghead.io/lessons/javascript-failsafe-combination-using-monoids)
- [Brian Lonsdorf, Egghead.io: A curated collection of Monoids and their uses](https://egghead.io/lessons/javascript-a-curated-collection-of-monoids-and-their-uses) 


## `IO`

[./io.js](./io.js)

- Impure functions become 'pure' when they are wrapped in a function.

```
const impureGetLocalStorage = (k) => localStorage.getItem(k);

// given the same input `k` always gets the same output, a function that applies
// `k` to `impureGetLocalStorage`.
const pureGetLocalStorage = (k) => () => impureGetLocalStorage(k);
```

- `IO` delays an impure action by capturing it in a function wrapper.
- Reason about the value contained by `IO` as the wrapped value and not the 
  wrapper, even though strictly speaking the value contained by `IO` is always a
  function.


### Links

*Articles*

- [Prof. Frisby, Chapter 8: Old McDonald Had Effects](https://drboolean.gitbooks.io/mostly-adequate-guide/content/ch8.html#old-mcdonald-had-effects)


## Task

[./task.js](./task.js)

A Task represents values that depend on time.


### Notes

- Pass the asynchronous action to Task.
- Pass functions to `map` that describe what you want to do with the Task's
  eventual value.
- Use `chain` to create a synchronous sequence of multiple asynchronous actions.
- Finally call `fork` to observe the effect(s). This is best done by the 
  app's entry point.


### Links

*Libraries*

- [folktale/data.task](https://github.com/folktale/data.task)

*Tutorials*

- [Brian Lonsdorf, Egghead.io: Capturing Side Effects in a Task](https://egghead.io/lessons/javascript-capturing-side-effects-in-a-task)
- [Brian Lonsdorf, Egghead.io: Using Task for Asynchronous Actions](https://egghead.io/lessons/javascript-using-task-for-asynchronous-actions)


## Laws of Functors

- A function has a `map` method.
- A functor obeys some laws:
  - `map` preserves function composition: 
    `fx.map(x => f(x)).map(x => g(x)) === fx.map(x => g(f(x)))`.
  - `const identity = x => x; fx.map(identity) === identity(fx)`.


### Links

*Tutorials*

- [Brian Lonsdorf, Egghead.io: You've been using Functors](https://egghead.io/lessons/javascript-you-ve-been-using-functors)


## Monads

[./monads.js](./monads.js)


Contract:

- Has an `of` method.
  - Sometimes called `pure`.
- Has a `chain` method.
  - `chain` joins two types together.
  - Sometimes called `flatMap`, `bind`, or `>>=`.


## Applicative Functors

[./applicative-functors](./applicative-functors.js)

- Has an `ap` method
- Law: `F(x).map(f) === F(f).ap(F(x))`


## Natural Transformations

- A natural transformation is a type conversion.
- A natural transformation takes in one type and returns a second type.
- A natural transformation must follow this law: `nt(x).map(f) = nt(x.map(f))`.
