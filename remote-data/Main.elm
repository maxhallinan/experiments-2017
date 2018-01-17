module Main exposing (..)

import Dict exposing (Dict)
import Html exposing (Html, text)
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


type Cache a b c
    = Empty (Health a) (Status b)
    | Filled (Health a) (Status b) c


type Health a
    = Valid
    | Invalid a


type Status a
    = Static
    | Loading a


type Source
    = Collection
    | Item Int


type alias Named =
    { name : String
    }


decodeName : Json.Decode.Decoder String
decodeName =
    Json.Decode.field "name" Json.Decode.string


decodeNamed : Json.Decode.Decoder Named
decodeNamed =
    Json.Decode.map Named decodeName


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NamedsRequest ->
            ( { model | nameds = Empty Valid (Loading Collection) }, Cmd.none )

        NamedsResponse (Err e) ->
            ( { model | nameds = Empty (Invalid e) Static }, Cmd.none )

        NamedsResponse (Ok ns) ->
            ( { model | nameds = Filled Valid Static ns }, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    case model.nameds of
        Empty Valid Static ->
            text "NotAsked"

        Empty Valid (Loading _) ->
            text "Loading"

        Empty (Invalid _) _ ->
            text "Failure"

        Filled Valid Static ns ->
            text <| String.join " " <| List.map .name ns

        _ ->
            text "Unreachable state"
