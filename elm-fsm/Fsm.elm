module Fsm exposing (..)

{-
   Approach 1: extend the RemoteData type.
-}


type RemoteData
    = EmptyValid -- no error, no data
    | EmptyPendingItem
    | EmptyPendingCollection
    | EmptyErrorItems (List ItemError) -- error, id
    | EmptyErrorCollection a -- error
    | CachedValid d -- data
    | CachedPendingItem d -- data
    | CachedPendingCollection d -- data
    | CachedErrorItems (List ItemError) d -- error, id, data
    | CachedErrorCollection e d -- error, data



{-
   Approach 2: shift away from the semantics of an HTTP request towards the
   semantics of a cache.

   Init

   Empty Pending

   Empty Valid

   Empty (Invalid e)

   Primed Pending Collection

   Primed (Valid d) Collection

   Primed (Invalid e) Collection
-}


type Health
    = Pending
    | Valid
    | Invalid e


type Cache
    = Init
    | Empty Health
    | Primed Health d


type Collection
    = Dict Int Cache


type alias View =
    { onEnter : State -> Html a
    , states : List Cache
    }
