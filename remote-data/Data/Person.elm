module Data.Person
    exposing
        ( Person
        , decodePerson
        , decodePersonCollection
        )

import Json.Decode


type alias Person =
    { name : String
    , url : String
    , hairColor : Maybe String
    }


decodeHairColor : Json.Decode.Decoder (Maybe String)
decodeHairColor =
    Json.Decode.field "hair_color" Json.Decode.string
        |> Json.Decode.map Just


decodeName : Json.Decode.Decoder String
decodeName =
    Json.Decode.field "name" Json.Decode.string


decodeUrl : Json.Decode.Decoder String
decodeUrl =
    Json.Decode.field "url" Json.Decode.string


decodePerson_ : Json.Decode.Decoder Person
decodePerson_ =
    Json.Decode.map3
        Person
        decodeName
        decodeUrl
        (Json.Decode.succeed Nothing)


decodePerson : Json.Decode.Decoder Person
decodePerson =
    Json.Decode.map3
        Person
        decodeName
        decodeUrl
        decodeHairColor


decodePersonCollection : Json.Decode.Decoder (List Person)
decodePersonCollection =
    Json.Decode.field "results" (Json.Decode.list decodePerson_)


decodeError : Json.Decode.Decoder String
decodeError =
    Json.Decode.field "detail" Json.Decode.string
