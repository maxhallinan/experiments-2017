# typescript-intro


## Notes


### Arrays

```typescript
let list: number[];
// Or `let list: Array<number>;`
list = [ 0, 1, 2, 3 ]; // OK
list = [ '0', '1', '2', '3', ]; // Error
```

- Elements must have a uniform type.


### Tuples

```typescript
let x: [number, string];
x = [ 1, 'one', ]; // OK
x = [ 'one', 1, ]; // Error
```

- Type of a fixed number of array elements is known.
- Type of elements does not need to be the same.


### Enum

```typescript
enum Stuff { Foo, Bar, Baz, }
let stuffA: Stuff = Stuff.Foo;
let stuffB: Stuff = Stuff.Bar;
let stuffC: Stuff = Stuff.Baz;

console.log(stuffA); // 0
console.log(stuffB); // 1
console.log(stuffC); // 2

enum Things { Foo=1212, Bar=3333, Baz=39239, }
let thingsFoo: Things = Things.Foo;
let thingsBar: Things = Things.Bar;
let thingsBaz: Things = Things.Baz;

console.log(thingsFoo); // 1212
console.log(thingsBar); // 3333
console.log(thingsBaz); // 39239
```

- TypeScript adds the `Enum` datatype.
- `Enum` gives human-readable names to numerical values.
- `Enum` starts numbering members at 0.


### `any`

- Alias for any value. 
- A way to opt out of type checking.


### `void`

- The opposite of `any`.
- `void` is `null` or `undefined`.


### `never`

```typescript
function throwErr(message: string): never {
  throw new Error(message);
}
```

- `never` represents types of values that never occur.
- `never` is the type of a function that never returns.


### Type assertions

```typescript
// two syntaxes:
let a: any = 'a';
let aLength: number = (<string>a).length;

let b: any = 'b';
let bLength: number = (b as string).length;
```

- A type assertion tells the compiler to treat a value as a certain type even
  if the type of that value is not known to the compiler.
- Type assertions tell the compiler "Trust me. I know what I'm doing".


### Interfaces

#### Object interfaces

- TypeScript focuses on duck-typing.
  - Compiler focuses on the shape of values.

```typescript
interface FooBarBaz {
  // required property
  foo: string;
  // optional property
  bar?: string;
  // read-only property
  // compiler will throw an error if there is an assignment to this field
  readonly baz: string;
}

const logFoo = (f: FooBarBaz): void => console.log(f.foo);
const logBar = (f: FooBarBaz): void => console.log(f.bar);

// read-only error
// const writeBaz = (f: FooBarBaz): void => { f.baz = 'BAZ'; }; // read-only error

// missing property error
// const a: FooBarBaz = { bar: 'bar', };
```

- Excess Property Checks
  - An "excess property" is a property in an object that is not defined by its
    type.
  - If an object literal has any properties that the 'target type' does not have,
    the compiler will throw an error.

```typescript
interface FooBarBaz {
  foo: string;
  bar?: string;
  baz: string;
}

// error: 'qux' does not exist in type 'FooBarBaz'
const a: FooBarBaz = {
  foo: 'foo',
  bar: 'bar',
  baz: 'baz',
  qux: 'qux',
};
```


#### Function interfaces

```typescript
// Function interface syntax
interface StrSearch {
  (source: string, subString: string): boolean;
}

let searchStr: StrSearch; 

// implements the StrSearch interface
// parameter names do not need to be the same
searchStr = (src: string, sub: string): boolean =>
  src.search(sub) > -1;
```
