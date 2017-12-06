module Cache exposing (..)

{-
   The states of a RemoteData cache

   no data cached
   no data cached, request pending
   no data cached, request error for collection
   data cached
   data cached, request pending for collection
   data cached, request pending for item
   data cached, request error for collection
   data cached, request error for item in collection

   Empty
   EmptyPendingItem
   EmptyPendingCollection
   EmptyErrorItem
   EmptyErrorCollection
   Cached
   CachedPendingItem
   CachedPendingCollection
   CachedErrorItem
   CachedErrorCollection
-}


type Health
    = Pending
    | Valid
    | Invalid


type Source
    = Collection
    | Item Int


type Event
    = Request Source
    | Success a
    | Error e



-- type State
--     = EmptyValid -- no error, no data
--     | EmptyPendingItem
--     | EmptyPendingCollection
--     | EmptyErrorItems (List ItemError) -- error, id
--     | EmptyErrorCollection a -- error
--     | CachedValid d -- data
--     | CachedPendingItem d -- data
--     | CachedPendingCollection d -- data
--     | CachedErrorItems (List ItemError) d -- error, id, data
--     | CachedErrorCollection e d -- error, data


type State
    = Init
    | Empty ( Health, Source )
    | Cached ( Health, Source ) a


transition : Action -> State -> State
transition action state =
    case state of
        Empty ( Pending, Item _ ) ->
            case action of
                Request Item id ->
                    Empty ( Pending, Item id )

                Request Collection ->
                    Empty ( Pending, Collection )

                Success data ->
                    Cached ( Valid, Item id ) data

                Error error ->
                    Empty ( Invalid error, Item id )

        Empty ( Pending, Collection ) ->
            case action of
                Request Item id ->
                    Empty ( Pending, Item id )

                Request Collection ->
                    state

                Success data ->
                    Cached ( Valid, Collection ) data

                Error error ->
                    Empty ( Invalid error, Collection )

        Empty ( Invalid err, Item id ) ->
            False

        Empty ( Invalid err, Collection ) ->
            False

        Cached ( Pending, Item id ) ->
            False

        Cached ( Pending, Collection _ ) ->
            False

        Cached ( Invalid err, Item id ) ->
            False

        Cached ( Invalid err, Collection xs ) ->
            False
