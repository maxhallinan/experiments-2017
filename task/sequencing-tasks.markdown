# Guide to Folktale 2 Task

What is a data structure? There is code that is written to do what you want and 
there is code written to help you do what you want. A Task falls into the latter 
category. A Task exists to structure how you think about what you're doing when 
what you're doing is getting an asynchronous value.

- What is a Task?
    - "A data structure that models asynchronous actions, supporting safe cancellation and automatic resource handling." [folktale](http://folktale.origamitower.com/api/v2.0.0/en/folktale.concurrency.task.html)
- Make a distinction between the idea of a Task and the implementation of that idea.
    - For example, the difference between `fork` from `data.task` and `run` from `folktale/concurrency/task`.
    - So then the question is, what does the implementation look like?
- How to create a task
- How to transform a task
- How to run a task
- How to sequence a task
- Task implements some of the fantasy-land algebras
    - "An algebra is a set of values, a set of operators that it is closed under and some laws it must obey."
Task is a monad, so we expect it to have these methods:

## Task

[Task fantasy-land](http://folktale.origamitower.com/api/v2.0.0/en/folktale.concurrency.future._future._future.html#cat-fantasy-land)

- (Functor) `map`
- (Apply) `ap`
- (Applicative) `of`
- (Chain) `chain`
- (Monad) `M.of(a).chain(f) === f(a)` and `m.chain(M.of) === m`
- (Bifunctor) `bimap(fA, fB)`

## Future

[Future fantasy-land](http://folktale.origamitower.com/api/v2.0.0/en/folktale.concurrency.future._future._future.html#cat-fantasy-land)

- `of`
- `chain`


Task
- fantasy-land/ap
- fantasy-land/bimap
- fantasy-land/chain
- fantasy-land/map

Future
- fantasy-land/ap
- fantasy-land/bimap
- fantasy-land/chain
- fantasy-land/map


- How to create a Task.
- How to read the Folktale 2 documentation.
    - [API documentation root](http://folktale.origamitower.com/api/v2.0.0/en/folktale.html)
    - The documentation structure mirrors the project structure.
    -  [Folktale 2 source hierarchy](http://folktale.origamitower.com/docs/v2.0.0/contributing/organisation/#source-hierarchy)
- How to transform a Task?

# Sequencing tasks

## What is the difference between Promises and Tasks

## Converting a Promise to a Future

## Representing one API call as a Task

## Representing two API calls as a sequence of Tasks

## A sequence of one or more Tasks

- call a function when the api call is going to be made
- make the api call
- call a function if the api call is successful
    - get a value from the api call response
    - make a second api call
        - call a function when the api call is going to be made
        - make the api call
        - call a function if the api call is a success
        - call a function if the api call is a failure
- call a function if the api call is a failure


