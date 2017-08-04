# fp-containers


## Notes

### `Box`

[./box.js](./box.js).

- Box can also be called Container or the Identity functor.
- Box is a Functor.
    - A Functor is a type that implements `map` and obeys some laws.
    - Functor could also be called Mappable.
- Enables composing transformations of that value without storing intermediate values.


### `Either`

[./either.js](./either.js).

- `Either` is a type that returns one of two subtypes: `Right` or `Left`.
- `Either` tests `x`. If the test succeeds, it returns `Right x` and if it fails, 
  it returns `Left x`.
- `Right` and `Left` have the same methods but these methods behave differently.
- `Right.map` and `Left.map` both take `fn`, but `Left.map` will not call `fn`.
- `Right.fold` and `Left.fold` both take `f, g`. `Right.fold` calls `g(x)` and
  `Left.fold` calls `f(x)`.
- This interface allows things like handling unexpected or invalid values without
  risking throwing an error.


## Links

**Articles**

- [Chapter 8: Tupperware](https://drboolean.gitbooks.io/mostly-adequate-guide/content/ch8.html)

**Tutorials**

- [Egghead: Create linear data flow with container types (Box)](https://egghead.io/lessons/javascript-linear-data-flow-with-container-style-types-box)
- [Egghead: Refactoring imperative code to single compose expression using Box](https://egghead.io/lessons/javascript-refactoring-imperative-code-to-a-single-composed-expression-using-box)
