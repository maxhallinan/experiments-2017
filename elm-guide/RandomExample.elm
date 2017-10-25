module Main exposing (..)

import Html exposing (Html, button, div, p, text)
import Html.Events exposing (onClick)
import Random


main =
    Html.program
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    { dieFace : Int
    }


init : ( Model, Cmd Msg )
init =
    ( Model 1, Cmd.none )



-- UPDATE


type Msg
    = Roll
    | NewFace Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Roll ->
            ( model, Random.generate NewFace (Random.int 1 6) )

        NewFace n ->
            ( { model | dieFace = n }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ p [] [ text ("The random number is " ++ toString model.dieFace) ]
        , button [ onClick Roll ] [ text "Get a random number" ]
        ]
