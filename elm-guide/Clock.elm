module Clock exposing (..)

import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Time exposing (Time, second)


main =
    Html.program
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }



-- MODEL


type Status
    = Started
    | Stopped


type alias Model =
    { status : Status
    , time : Time
    }


init : ( Model, Cmd Msg )
init =
    ( Model Started 0, Cmd.none )



-- UPDATE


type Msg
    = Tick Time
    | Pause Status


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            ( { model | time = newTime }, Cmd.none )

        Pause newStatus ->
            ( { model | status = newStatus }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.status of
        Started ->
            Time.every second Tick

        Stopped ->
            Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    let
        angle =
            turns (Time.inMinutes model.time)

        handX =
            toString (50 + 40 * cos angle)

        handY =
            toString (50 + 40 * sin angle)

        newStatus =
            case model.status of
                Started ->
                    Stopped

                Stopped ->
                    Started
    in
        div []
            [ svg [ viewBox "0 0 100 100", width "300px" ]
                [ circle [ cx "50", cy "50", r "45", fill "#0B79CE" ] []
                , line [ x1 "50", y1 "50", x2 handX, y2 handY, stroke "#023963" ] []
                ]
            , button [ onClick (Pause newStatus) ]
                [ Html.text "Pause clock" ]
            ]
