const foo = pattern([`a`, `b`,], {
  // expressions
  guards: [
    [ 
      (a, b) => a === b, 
      (a, b) => a + b,
    ]
  ],
  // values
  patterns: [
    [ 
      [ 
        pattern.empty, 
        { a: 'one', b: 'two', }, 
      ], 
      () => val 
    ]
  ],
});
// pattern
// guard
// with
// as
// let
