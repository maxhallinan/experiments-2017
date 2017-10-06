# Can I cache paginated data without causing memory problems?

- We are not aware of any memory problems specific to Redux.
- Memory in the browser is limited and it is possible for your application 
  to use too much memory.
- Generally, applications suffer when they cache exceptionally large amounts 
  of data. 
- If your app caches a heavy dataset or accumulates cached data over the course
  of a long-running session, then it is wise to be concerned about efficient
  memory consumption.
- But we are not aware of any memory problems specific to Redux.

- We are not aware of any memory problems specific to Redux. 
- Caching data in the Redux state tree is not likely to cause memory problems that 
  you wouldn't have if your application used a different state management system.

- The Redux state tree is, in the end, just an object.
- It is unlikely that Redux itself is responsible for memory usage. 
- Browsers have a memory limit.
- Should be aware of how much memory your application is using. 
- It is unlikely that Redux itself is responsible for memory usage.
- Times when memory use can be a problem:
  - When you have a large amount of data. Records that are large or a large amount
    of small records.
  - When your app has long-living sessions and memory use grows over time.

## Links

- [Twitter: "...lots of concerns over having "too much data in a state tree""](https://twitter.com/acemarke/status/804071531844423683)
- []()

# How can I effectively manage memory consumption?

- Denormalize data: store relationships (ids)

