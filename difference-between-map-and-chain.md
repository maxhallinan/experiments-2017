# `map` and `chain` in Fantasy Land

Fantasy Land specifies two algebraic structures: `Functor` and `Chain`. It is common
to encounter algebraic data types which implement both specifications. The 
`Maybe` and `Either` monads are two examples. Because implementations of `Functor` 
and `Chain` so often coincide in the same type, it is (or might be) common 
to see a mix of `map` and `chain`, and to wonder when should I chain and 
when should I map?

The similarities and differences between these two methods are expressed by 
their type signatures. 

[map method](https://github.com/fantasyland/fantasy-land#map-method)

```
map :: Functor f => f a ~> (a -> b) -> f b
```

[chain method](https://github.com/fantasyland/fantasy-land#chain-method)

```
chain :: Chain m => m a ~> (a -> m b) -> m b
```

Type signatures often look a bit cryptic. For many (including me) who
haven't spent a lot of time reading type signatures, it can be hard to understand
why this notation is useful for expressing abstractions.

These type signatures are mostly identical. Both start with a type variable: `f`
or `m`. A type variable can stand for any type, just as a variable name can stand
for any value. But, `f` and `m` in the context of `map` and `chain` 
aren't just *any* type. So the type signatures place a constraint on `f` and 
`m` using the `=>` notation.

**map**

```
Functor f => f
```

`f` must be a `Functor`.

**chain**

```
Chain m => m
```

`m` must be a `Chain`.

Then the type signature uses the `~>` notation to tell us that `map` and `chain` 
are methods.

**map**

```
f a ~>
```

`map` is a method of `f`.

**chain**

```
m a ~>
```

Likewise, `chain` is a method of `m`.

Here we notice a second type variable `a`. `a` here really is any type. The type
signature does not place any constraints on the type of `a`. This is because 
the type of `a` is unimportant. In fact, we prefer not to think about its type here. 
We just want to know that each of our types is holding some value. 
This is expressed as `f a` and `m a`.

Let's skip to the signature ends for a moment. You might notice that both 
type signatures end in (nearly) the same way.

**map**

```
-> f b
```

`map` returns the same type `f`. So `map` is called on a Functor and returns a Functor.

**chain**

```
-> m b
```

`chain` returns the same type `m`, having been called on a Chain and returning a Chain. 

As you skipped to the end of these signatures, you might have noticed that 
`f a` became `f b` and  `m a` became `m b`. The types holding those values did not change. 
`f` is still `f` and `m` is still `m`. But both `map` and `chain` have transformed `a` to `b`.

Where does this transformation happen? Both `map` and `chain` take functions. These
functions are the transformation of `a` to `b`. And the type signature of these
functions is where we find the difference between `map` and `chain`.

Keep in mind here that both `map` and `chain` must return the types they were called
on: `f b` for `map` and `m b` for `chain`.

**map**

```
(a -> b)
```

The `map` function simply transforms `a` to `b`. It does not know anything about type `f`. So
the `map` method itself is responsible for finally putting `b` into `f` in order
to satisfy the return type `f b`.

**chain**

```
(a -> m b)
```

The `chain` function transforms `a` to `b` *and* puts `b` into the correct type. 
Because this function returns `m b` and because `chain` returns `m b`, 
we know that `chain` itself, unlike `map` is not doing anything to the return 
value of this function. 

What does all of this mean?

Transformations of `a` to `b` are one of the central concerns of functional 
programming. A program is essentially a combination (composition) of transformations.
But not all transformations are the same. As the type signatures for `map` and 
`chain` show us, sometimes you have a transformation of `a -> b` and sometimes 
you have a transformation of `a -> f b`. So `map` and `chain`, and other 
operators account for these differences.
