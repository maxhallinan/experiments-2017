module Data.Collection exposing (Collection)

import Dict exposing (Dict)


type alias Collection a =
    { entities : Dict String a
    , displayOrder : List String
    }
