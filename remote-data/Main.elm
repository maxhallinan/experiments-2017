module Main exposing (..)

import Dict exposing (Dict)
import Html exposing (Html, button, li, ul, text)
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


getNamed : String -> Cmd Msg
getNamed url =
    Http.send NamedResponse <|
        Http.get url decodeNamed


getNameds : Cmd Msg
getNameds =
    Http.send NamedsResponse <|
        Http.get "https://swapi.co/api/people/" decodeNameds



-- Model


init : ( Model, Cmd Msg )
init =
    ( { nameds = Empty Valid Static }, getNameds )


type alias Model =
    { nameds : Cache Http.Error Source (List Named)
    }


type Source
    = Collection
    | Item Int


type alias Named =
    { name : String
    , url : String
    }


type alias EmptyState a b =
    { health : Health a
    , sync : Sync b
    }


type alias FilledState a b c =
    { health : Health a
    , sync : Sync b
    , data : c
    }


type Cache a b c
    = Empty
    | EmptyError a
    | EmptySync b
    | EmptyErrorSync a b
    | Filled c
    | FilledError a c
    | FilledSync b c
    | FilledErrorSync a b c


type alias Foo =
    { name : String
    }



-- Empty ->
--   Health ->
--     Sync ->
-- Filled ->
--   Health ->
--     Sync ->
-- emptyView


type alias ItemCache =
    Cache Http.Error Foo


type alias CollectionCache =
    Cache Http.Error (List Foo)


type Cache a b c
    = Empty (EmptyState a b)
    | Filled (FilledState a b c)


type Health a
    = Valid
    | Invalid a


type Sync a
    = Completed
    | Pending a


decodeName : Json.Decode.Decoder String
decodeName =
    Json.Decode.field "name" Json.Decode.string


decodeUrl : Json.Decode.Decoder String
decodeUrl =
    Json.Decode.field "url" Json.Decode.string


decodeNamed : Json.Decode.Decoder Named
decodeNamed =
    Json.Decode.map2 Named decodeName decodeUrl


decodeNameds : Json.Decode.Decoder (List Named)
decodeNameds =
    Json.Decode.field "results" (Json.Decode.list decodeNamed)


decodeError : Json.Decode.Decoder String
decodeError =
    Json.Decode.field "detail" Json.Decode.string



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Update


type Msg
    = NamedsRequest
    | NamedsResponse (Result Http.Error (List Named))
    | NamedRequest String
    | NamedRequest (Result Http.Error Named)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NamedsRequest ->
            ( { model | nameds = Empty Valid (Loading Collection) }, Cmd.none )

        NamedsResponse (Err e) ->
            ( { model | nameds = Empty (Invalid e) Static }, Cmd.none )

        NamedsResponse (Ok ns) ->
            ( { model | nameds = Filled Valid Static ns }, Cmd.none )

        NamedRequest url ->
            ( model, getNamed url )

        NamedResponse (Err e) ->
            ( { model | nameds = Empty (Invalid e) Static }, Cmd.none )

        NamedResponse (Ok n) ->
            ( { model | nameds = Filled Valid Static ns }, Cmd.none )



-- View


itemView : Named -> Html Msg
itemView named =
    li
        []
        [ button
            []
            [ text named.name
            ]
        ]


listView : List Named -> Html Msg
listView nameds =
    List.map itemView nameds
        |> ul []



-- emptyInvalidView : Cache Http.Error Source (List Named) -> Html Msg
-- emptyInvalidView nameds =
--     case nameds of
--         Empty (Invalid e) (Pending Collection) ->
--             emptyInvalidLoadingCollectionView e
--         Empty (Invalid e) (Pending (Item id)) ->
--             emptyInvalidLoadingItemView e id
--         Empty (Invalid e) _ ->
--             emptyInvalidErrorView e
-- emptyView : Cache Http.Error Source (List Named) -> Html Msg
-- emptyView nameds =
--     case nameds of
--         Empty Valid _ ->
--             emptyValid
--         Empty (Invalid e) _ ->
--             emptyInvalidView nameds


view : Model -> Html Msg
view model =
    case model.nameds of
        Empty error ->
            text "Empty"

        Loading error nameds ->
            text "Loading"

        Failure error nameds ->
            text "Failure"

        Success error nameds ->
            text "Success"
