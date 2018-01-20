module Main exposing (..)

import Dict exposing (Dict)
import Html exposing (Html, button, li, p, text, ul)
import Html.Events exposing (onClick)
import Http
import Json.Decode


main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- Http


getPerson : String -> Cmd Msg
getPerson url =
    Http.send (ItemResponse url) <|
        Http.get url decodePerson


getPersons : Cmd Msg
getPersons =
    Http.send CollectionResponse <|
        Http.get "https://swapi.co/api/people/" decodePersons



-- Model


init : ( Model, Cmd Msg )
init =
    ( { persons = NotAsked }, getPersons )


type alias Model =
    { persons : RemoteData Http.Error PersonCollection
    }


type alias PersonCollection =
    Collection (RemoteData Http.Error Person)


type RemoteData a b
    = NotAsked
    | Loading
    | Failure a
    | Success b


type alias Collection x =
    { collection : Dict String x
    , displayOrder : List String
    }


type alias Person =
    { name : String
    , url : String
    }


decodeName : Json.Decode.Decoder String
decodeName =
    Json.Decode.field "name" Json.Decode.string


decodeUrl : Json.Decode.Decoder String
decodeUrl =
    Json.Decode.field "url" Json.Decode.string


decodePerson : Json.Decode.Decoder Person
decodePerson =
    Json.Decode.map2 Person decodeName decodeUrl


decodePersons : Json.Decode.Decoder (List Person)
decodePersons =
    Json.Decode.field "results" (Json.Decode.list decodePerson)


decodeError : Json.Decode.Decoder String
decodeError =
    Json.Decode.field "detail" Json.Decode.string



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Update


type Msg
    = CollectionErrorRequest
    | CollectionErrorResponse (Result Http.Error (List Person))
    | CollectionRequest
    | CollectionResponse (Result Http.Error (List Person))
    | ItemDetailsRequest String
    | ItemDetailsResponse (Result Http.Error Person)
    | ItemErrorRequest String
    | ItemErrorResponse (Result Http.Error Person)
    | ItemRequest String
    | ItemResponse String (Result Http.Error Person)


type alias Url a =
    { a | url : String }


keyByUrl : Url a -> ( String, Url a )
keyByUrl x =
    ( x.url, x )


toUrlDict : List (Url a) -> Dict String (Url a)
toUrlDict xs =
    List.map keyByUrl xs
        |> Dict.fromList


toSuccess : String -> Person -> RemoteData Http.Error Person
toSuccess k person =
    Success person


refreshCollection : List Person -> PersonCollection
refreshCollection persons =
    { collection = Dict.map toSuccess <| toUrlDict persons
    , displayOrder = List.map .url persons
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CollectionRequest ->
            ( { model | persons = Loading }, Cmd.none )

        CollectionResponse (Err e) ->
            ( { model | persons = Failure e }, Cmd.none )

        CollectionResponse (Ok persons) ->
            ( { model | persons = Success <| refreshCollection persons }, Cmd.none )

        _ ->
            ( model, Cmd.none )


errorView : String -> Html Msg
errorView error =
    p
        []
        [ text "Error:"
        ]


itemView : Person -> Html Msg
itemView named =
    li
        []
        [ p
            []
            [ text named.name
            ]
        , button
            [ onClick (ItemDetailsRequest "")
            ]
            [ text "Get details"
            ]
        , button
            [ onClick (ItemErrorRequest "")
            ]
            [ text "Get error"
            ]
        ]


listView : List Person -> Html Msg
listView nameds =
    List.map itemView nameds
        |> ul []


view : Model -> Html Msg
view model =
    case model.persons of
        NotAsked ->
            text "Empty"

        Loading ->
            text "Loading"

        Failure error ->
            text "Failure"

        Success nameds ->
            text "Success"
