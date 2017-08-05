# fp-containers

Functional programming with composable container types.


## Notes


### `Box`

[./box.js](./box.js)

- Box can also be called Container or the Identity functor.
- Box is a Functor.
    - A Functor is a type that implements `map` and obeys some laws.
    - Functor could also be called Mappable.
- Enables composing transformations of that value without storing intermediate values.


#### Links

*Articles*

- [Prof. Frisby, Chapter 8: The Mighty Container](https://drboolean.gitbooks.io/mostly-adequate-guide/content/ch8.html#the-mighty-container)

*Tutorials*

- [Brian Lonsdorf, Egghead.io: Create linear data flow with container types (Box)](https://egghead.io/lessons/javascript-linear-data-flow-with-container-style-types-box)
- [Brain Lonsdorf, Egghead.io: Refactoring imperative code to single compose expression using Box](https://egghead.io/lessons/javascript-refactoring-imperative-code-to-a-single-composed-expression-using-box)


### `Maybe`

[./maybe.js](./maybe.js)

- A container type that handles possible `null` value.


### `Either`

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


#### Links

*Articles*

- [Prof. Frisby, Chapter 8: Schroedinger's Maybe](https://drboolean.gitbooks.io/mostly-adequate-guide/content/ch8.html#schrödingers-maybe)

*Tutorials*

- [Brian Lonsdorf, Egghead.io: Enforce a null check with composable code branching with Either](https://egghead.io/lessons/javascript-composable-code-branching-with-either)
- [Brain Lonsdorf, Egghead.io: Use chain for composable error handling with Either](https://egghead.io/lessons/javascript-composable-error-handling-with-either)


