module Data.Collection exposing (Collection, Entities)

import Dict exposing (Dict)


-- Helpers


keyByUrl : { a | url : String } -> ( String, { a | url : String } )
keyByUrl x =
    ( x.url, x )


type alias Collection a =
    { entities : Entities a
    , displayOrder : List String
    }


type alias Entities a =
    Dict String a


toEntities : (a -> String) -> List a -> Entities a
toEntities keyBy xs =
    List.map (\x -> ( keyBy x, x )) xs
        |> Dict.fromList
