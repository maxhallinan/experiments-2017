# Notes: "Slaying a UI Antipattern in Fantasyland"

[Slaying a UI Antipattern in Fantasyland](https://medium.com/javascript-inside/slaying-a-ui-antipattern-in-fantasyland-907cbc322d2a)


## The problem

There's remote data that's stored as a collection. Because that data is remote,
there has to be state around fetching it and a default value. Typically, this
pattern is a loading flag, `isLoading`, and an empty collection. The other
solution is to set the default value to `null`.

```javascript
// state
this.state = {
  isLoading: true,
  items: [],
};

// or
this.state = {
  // `null` while loading
  items: null,
};
```


## Solutions

### `Maybe`

[Folktale: `data.maybe`](http://docs.folktalejs.org/en/latest/api/data/maybe/index.html#module-data.maybe)

- `Maybe` is a container for a value that is not present.
    - `Just`: value is present.
    - `Nothing`: value is not present.

```javascript
// first
this.state = {
  // default
  items: Nothing(),
};

// and then, *maybe*
this.state = {
  items: Just(items),
};

// the loading state is inferred from Nothing
render() {
  return this.state.items.cata({
    Just: ({ value }) => this.renderItems(value),
    Nothing: () => this.renderLoading(),
  });
}
```

However, `Maybe` represents two states and there are potentially four UI states
for remote data:

- `NotAsked`
- `Loading`
- `Failure e`
- `Success a`


## Tagged Unions

Reference:

- [Folkale: Programming with Tagged Unions](http://folktale.origamitower.com/api/v2.0.0/en/folktale.adt.union.html#programming-with-tagged-unions)

Can represent these four states with a tagged union type. Tagged unions model
choices.

```javascript
const RemoteData = daggy.taggedSum('RemoteData', {
  NotAsked: [],
  Loading: [],
  Failure: ['err'],
  Success: ['data'],
});

class Items extends React {
  constructor(props) {
    super(props);
     
    this.state = {
      items: RemoteData.NotAsked,
    };
  }

  render() {
    return this.state.items.cata({
      NotAsked: () => this.renderInitial(), 
      Loading: () => this.renderLoading(),
      Failure: (err) => this.renderError(err),
      Success: (items) => this.renderItems(items),
    });
  }
}
```
